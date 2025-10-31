#
# Variant calling workflow adapted from the Biostar Handbook.
#

# Accession number of the Ebola (Mayinga, 1976) genome.
ACC=GCA_000848505

# Reference and annotation files (downloaded by toolbox).
REF=refs/ebola-1976.fa
GFF=refs/ebola-1976.gff

# Default SRR and sample alias.
SRR=SRR1553425
SAMPLE=EM110

# Limit reads for a quick demo (increase for full analysis).
N=5000

# Paths for output.
R1=reads/$(SAMPLE)_1.fastq
R2=reads/$(SAMPLE)_2.fastq
BAM=bam/$(SAMPLE).bam
VCF=vcf/$(SAMPLE).vcf.gz

# Make hygiene.
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

usage:
\t@echo '# SNP call demonstration'
\t@echo '# ACC=$(ACC)'
\t@echo '# SRR=$(SRR)'
\t@echo '# SAMPLE=$(SAMPLE)'
\t@echo '# BAM=$(BAM)'
\t@echo '# VCF=$(VCF)'
\t@echo '#'
\t@echo '# make bam      # reference, index, download reads, align -> BAM'
\t@echo '# make vcf      # call variants with bcftools -> VCF.GZ'
\t@echo '# make all      # run both'
\t@echo '# make clean    # remove generated files'
\t@echo '#'
\t@echo '# Override defaults: make SRR=SRR1553428 SAMPLE=EM111 all'

# Check toolbox.
CHECK_FILE := src/run/genbank.mk
$(CHECK_FILE):
\t@echo '# Please install Biostar Toolbox with: bio code'
\t@exit 1

# BAM creation.
bam: $(CHECK_FILE)
\t# Get reference genome & annotations
\tmake -f src/run/datasets.mk ACC=$(ACC) REF=$(REF) GFF=$(GFF) run
\t# Index reference
\tmake -f src/run/bwa.mk REF=$(REF) index
\t# Download reads
\tmake -f src/run/sra.mk SRR=$(SRR) R1=$(R1) R2=$(R2) N=$(N) run
\t# Align reads with readgroup sample name
\tmake -f src/run/bwa.mk SM=$(SAMPLE) REF=$(REF) R1=$(R1) R2=$(R2) BAM=$(BAM) run stats

# VCF calling.
vcf:
\tmake -f src/run/bcftools.mk REF=$(REF) BAM=$(BAM) VCF=$(VCF) run

# Both.
all: bam vcf

# Clean.
clean:
\trm -rf ncbi_dataset/data/$(ACC)
\trm -rf $(REF) $(GFF) $(R1) $(R2) $(BAM) $(VCF) vcf/merged.vcf.gz vcf/merged.vcf.gz.tbi

.PHONY: bam vcf all usage clean
