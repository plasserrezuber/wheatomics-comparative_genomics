#!/bin/bash
#SBATCH --nodes=1 # Un noeud par tache
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=bwaIsbp
#SBATCH --partition=fast

####################################################################################
# DEFINITION VARIABLES
####################################################################################
DATABANK='/storage/groups/gdec/shared/triticum_aestivum/chinese_spring/iwgsc/REFSEQV2/v2.1'

INPUT='/home/palasser/results/juicer-1.6_results/references'
OUTPUT='/home/palasser/results/bwa/isbp_REFSEQV2_vs_RENAN_PSEUDOV2'
mkdir $OUTPUT

####################################################################################
# FASTA ISBPs
####################################################################################
ml gcc/4.8.4 bedtools

#fastaFromBed=bedtools getfasta
#NB: $DATABANK/annotation/ISBPs/Tae.Chinese_Spring.refSeqv2.1.ISBPs.bed est l'annotation de novo des isbp sur REFSEQV2
fastaFromBed -name -fi $DATABANK/CS_pesudo_v2.1.fa \
-bed $DATABANK/annotation/ISBPs/Tae.Chinese_Spring.refSeqv2.1.ISBPs.bed \
-fo /home/palasser/data/REFSEQV2/Tae.Chinese_Spring.refSeqv2.1.ISBPs.fasta

####################################################################################
# BWA
####################################################################################
ml gcc/8.1.0 samtools/1.9 bwa/0.7.17

##bwa index $INPUT/TaeRenan_refseq_v2.0.fa

bwa mem -t $SLURM_CPUS_PER_TASK $INPUT/TaeRenan_refseq_v2.0.fa /home/palasser/data/REFSEQV2/Tae.Chinese_Spring.refSeqv2.1.ISBPs.fasta \
|samtools view -bS - |samtools sort -o $OUTPUT/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2.bam


## RAPPEL: bwa met une mapQ0 pour les multi best hit (meme score d'alignement sur plusieurs loci); mapQ30 => 1/1000 chance que l'alignement soit faut

ml python/3.7.1 pysam/0.15.3
## filterBWA.py 2 mismatch, cov 100%, mapq30
filterBWA.py $OUTPUT/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2.bam $OUTPUT/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2_filtered.bam 30 2 1 0 0 2> $OUTPUT/filterBWA.log

ml gcc/4.8.4 bedtools
bedtools bamtobed -i $OUTPUT/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2_filtered.bam > $OUTPUT/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2_filtered.bed

join -t$'\t' -1 3 -2 3 <(cut -f1,2,4 $DATABANK/annotation/ISBPs/Tae.Chinese_Spring.refSeqv2.1.ISBPs.bed |sort -k3,3) \
<(cut -f1,2,4 $OUTPUT/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2_filtered.bed |sort -k3,3) |sort -k2,2 -k3,3n |sed 's/Chr/chr/' \
|gawk '{ if ($2==$4) print $0 }' > $OUTPUT/ISBPS_REFSEQV2_RENAN_PSEUDOV2_input_dotplot.txt

