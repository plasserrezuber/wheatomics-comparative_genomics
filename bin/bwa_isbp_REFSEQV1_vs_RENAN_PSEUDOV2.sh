#!/bin/bash
#SBATCH --nodes=1 # Un noeud par tache
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=bwaIsbp
#SBATCH --partition=fast

####################################################################################
# DEFINITION VARIABLES
####################################################################################
DATABANK='/storage/groups/gdec/shared/triticum_aestivum/chinese_spring/iwgsc/REFSEQV1/fasta'

INPUT='/home/palasser/data/RENAN_v2_pseudo'
OUTPUT='/home/palasser/results/bwa/isbp_REFSEQV1_vs_RENAN_PSEUDOV2'
mkdir $OUTPUT

####################################################################################
# BWA
####################################################################################
ml gcc/8.1.0 samtools/1.9 bwa/0.7.17

##bwa index $INPUT/TaeRenan_refseq_v2.0.fa

bwa mem -t $SLURM_CPUS_PER_TASK $INPUT/TaeRenan_refseq_v2.0.fa $DATABANK/iwgsc_refseqv1.0_ISBP_curated.fasta \
|samtools view -bS - |samtools sort -o $OUTPUT/ISBPS_REFSEQV1_vs_RENAN_PSEUDOV2.bam


## RAPPEL: bwa met une mapQ0 pour les multi best hit (meme score d'alignement sur plusieurs loci); mapQ30 => 1/1000 chance que l'alignement soit faut
ml python/3.7.1 pysam/0.15.3
## filterBWA.py 2 mismatch, cov 100%, mapq30
filterBWA.py $OUTPUT/ISBPS_REFSEQV1_vs_RENAN_PSEUDOV2.bam $OUTPUT/ISBPS_REFSEQV1_vs_RENAN_PSEUDOV2_filtered.bam 30 2 1 0 0 2> $OUTPUT/filterBWA.log

ml gcc/4.8.4 bedtools
bedtools bamtobed -i $OUTPUT/ISBPS_REFSEQV1_vs_RENAN_PSEUDOV2_filtered.bam > $OUTPUT/ISBPS_REFSEQV1_vs_RENAN_PSEUDOV2_filtered.bed


