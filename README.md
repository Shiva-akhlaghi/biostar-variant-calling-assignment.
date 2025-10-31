# Biostar Handbook – *How to Call Variants* (Assignment Repo)

This repo mirrors the Biostar Handbook exercise: **How to call variants**  
Link: https://www.biostarhandbook.com/appbio/methods/snpcall/

It contains a ready-to-run **Makefile** and a checklist for generating evidence (screenshots/logs) and pushing to GitHub for grading.

---

## Quickstart

> **Requirements (Linux/macOS or WSL):**
> - `git`, `make`, `conda` or `mamba`
> - `bwa`, `samtools`, `bcftools`, `sra-tools`, `csvtk`
> - Biostar **Toolbox** (installs rules that this Makefile uses): `bio code`

### 1) Create & activate a conda env (suggested)

```bash
mamba create -n biostar-snp -y bwa samtools bcftools sra-tools csvtk
conda activate biostar-snp
```

### 2) Install the Biostar Toolbox

This Makefile depends on the Biostar Handbook toolbox rules (e.g. `src/run/*.mk`). Install it once:

```bash
bio code
```

> If `bio` is not found, install the Bioinformatics Toolbox following the *🧰 Bioinformatics Toolbox* section in the Handbook, or ask your TA for the local bootstrap installer. After running `bio code`, you should have a `src/run/` folder in your working directory.

### 3) Run the pipeline

Default sample is **SRR1553425** (alias **EM110**). The steps:

```bash
# show usage and current variables
make usage

# create alignment (BAM)
make bam

# call variants (VCF.GZ)
make vcf

# do both
make all
```

Expected outputs after `make all`:

```
bam/EM110.bam
vcf/EM110.vcf.gz
```

### 4) Process additional samples

```bash
# Example: EM111
make SRR=SRR1553428 SAMPLE=EM111 all

# Example: EM113
make SRR=SRR1553432 SAMPLE=EM113 all
```

### 5) Merge VCFs

```bash
bcftools merge -0 vcf/EM*.vcf.gz -O z > vcf/merged.vcf.gz
bcftools index vcf/merged.vcf.gz
```

---

## Evidence checklist (take screenshots)

Please capture terminal screenshots for **each** item:

1. `make usage` output (shows ACC/SRR/SAMPLE/BAM/VCF variables).
2. Successful end of `make bam` showing the generated `bam/EM110.bam` (and `ls -lh bam/`).
3. Successful end of `make vcf` showing `vcf/EM110.vcf.gz` and its index (and `ls -lh vcf/`).
4. First 20 header lines from the VCF:
   ```bash
   bcftools view -h vcf/EM110.vcf.gz | head -n 20
   ```
5. One additional sample processed (e.g., EM111): `make SRR=SRR1553428 SAMPLE=EM111 all` + `ls vcf/EM111.vcf.gz`.
6. (Optional) Merge step + `bcftools index vcf/merged.vcf.gz`.
7. (Optional) Summary stats:
   ```bash
   bcftools stats vcf/EM110.vcf.gz | head -n 20
   ```

Save images into `docs/screenshots/` and commit them.

---

## What is happening under the hood?

- **Reads** (FASTQ) are fetched using SRA run accession → `reads/`
- **Reference genome** (Ebola Mayinga, 1976) is downloaded & indexed → `refs/`
- **Alignment** with BWA-MEM2 or BWA to create `bam/EM110.bam`
- **Variant calling** with `bcftools` to produce `vcf/EM110.vcf.gz`

The actual rule implementations are in the Biostar Toolbox (`src/run/*.mk`), which this Makefile invokes.

---

## Submit to GitHub

```bash
git init
git add .
git commit -m "Biostar Handbook - How to call variants (completed)"
git branch -M main
git remote add origin https://github.com/<your-username>/biostar-variant-calling-assignment.git
git push -u origin main
```

Then paste the **GitHub repo URL** in your assignment form.

---

## Troubleshooting

- **bio: command not found** → Install the Biostar Toolbox as per the Handbook; ensure `bio` is on your `PATH`.
- **Permission denied writing folders** → Run in a writable directory (not system folders); avoid `sudo`.
- **SRA download errors** → Try `prefetch SRR...` from `sra-tools`, or switch networks/VPN; some campuses block SRA.
- **bcftools not found** → Confirm conda env is activated: `conda activate biostar-snp`.
- **Windows** → Use WSL (Ubuntu). Install conda and packages inside WSL.

---

## References

- Biostar Handbook: *How to call variants*  
- 2014 Ebola surveillance study (PRJNA257197)
