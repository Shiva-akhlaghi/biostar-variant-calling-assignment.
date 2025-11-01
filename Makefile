.RECIPEPREFIX := >
SHELL := bash

# --- Settings ---
REF_DIR := refs
REF := $(REF_DIR)/ebola-1976.fa

# Default dataset (matches assignment)
SRR := SRR1553425
SAMPLE := EM110

READS_DIR := reads
R1 := $(READS_DIR)/$(SRR)_1.fastq
R2 := $(READS_DIR)/$(SRR)_2.fastq

BAM_DIR := bam
BAM := $(BAM_DIR)/$(SAMPLE).bam

VCF_DIR := vcf
VCF := $(VCF_DIR)/$(SAMPLE).vcf.gz

usage:
> @echo "# Standalone SNP call demo"
> @echo "# SRR=$(SRR)"
> @echo "# SAMPLE=$(SAMPLE)"
> @echo "# REF=$(REF)"
> @echo "# BAM=$(BAM)"
> @echo "# VCF=$(VCF)"
> @echo "#"
> @echo "# make all        # ref + reads + align + call"
> @echo "# make bam        # stop after BAM"
> @echo "# make vcf        # call variants (after BAM)"
> @echo "# Override: make SRR=SRR1553428 SAMPLE=EM111 all"

# --- Reference (Ebola Mayinga, 1976) ---
$(REF):
> mkdir -p $(REF_DIR)
> echo "# Downloading Ebola reference (AF086833.2) FASTA ..."
> curl -L "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF086833.2&db=nuccore&report=fasta" -o $(REF)
> test -s $(REF)
> echo "# Indexing reference ..."
> bwa index $(REF)
> samtools faidx $(REF)

# --- Reads (SRA) ---
$(R1) $(R2):
> mkdir -p $(READS_DIR)
> echo "# Fetching $(SRR) with fasterq-dump ..."
> prefetch $(SRR) || true
> fasterq-dump --split-files -O $(READS_DIR) $(SRR)
> test -s $(R1) && test -s $(R2)

# --- Alignment (BAM) ---
$(BAM): $(REF) $(R1) $(R2)
> mkdir -p $(BAM_DIR)
> echo "# Aligning with BWA-MEM ..."
> bwa mem -t 2 -R "@RG\tID:$(SAMPLE)\tSM:$(SAMPLE)" $(REF) $(R1) $(R2) \
>   | samtools sort -@ 2 -o $(BAM) -
> samtools index $(BAM)

bam: $(BAM)

# --- Variant calling (VCF) ---
$(VCF): $(BAM)
> mkdir -p $(VCF_DIR)
> echo "# Calling variants with bcftools ..."
> bcftools mpileup -Ou -f $(REF) $(BAM) \
>   | bcftools call -mv -Oz -o $(VCF)
> bcftools index -t $(VCF)

vcf: $(VCF)

all: $(VCF)

clean:
> rm -rf $(REF_DIR) $(READS_DIR) $(BAM_DIR) $(VCF_DIR) ncbi/public/sra

.PHONY: usage bam vcf all clean
