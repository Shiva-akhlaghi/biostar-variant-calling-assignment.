#!/usr/bin/env bash
# Convenience helper: run common commands and save logs for screenshots.

set -euo pipefail

echo "== Usage =="
make usage | tee run_usage.txt

echo "== Run BAM =="
make bam | tee run_bam.log

echo "== Run VCF =="
make vcf | tee run_vcf.log

echo "== List outputs =="
ls -lh bam/ vcf/ | tee run_ls.txt

echo "== VCF header preview =="
bcftools view -h vcf/EM110.vcf.gz | head -n 20 | tee vcf_header.txt

echo "All done."
