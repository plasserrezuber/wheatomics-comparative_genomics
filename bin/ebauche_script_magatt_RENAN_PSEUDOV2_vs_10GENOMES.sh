#!/bin/bash
#SBATCH --nodes=1 # Un noeud par tache
#SBATCH --ntasks=1
#SBATCH --mem=8G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=bwaIsbp
#SBATCH --partition=fast
#SBATCH --array=0-9

####################################################################################
# DEFINITION VARIABLES
####################################################################################
genomes=("arianaLrFor" "CDC_Landmark" "CDC_Stanley" "Jagger" "Julius" "LongReach_Lancer" "Mace" "Norin61" "SY_Mattis" "spelta")
genome=${genomes[$SLURM_ARRAY_TASK_ID]}

INPUT='/home/palasser/results/bwa/isbp_RENAN_PSEUDOV2_vs_10GENOMES'
OUTPUT='/home/palasser/results/magatt/magatt_chr1_Renan_'${genome}
mkdir -p $OUTPUT/data

cd $OUTPUT

ml gcc/8.1.0 samtools/1.9
####################################################################################
## FICHIERs ENTREE MAGATT
####################################################################################
#mapping bwa des isbp de la query (Renan) sur les 10 genomes
samtools index -@8 $INPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}_filtered.bam
samtools view -@8 -b $INPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}_filtered.bam chr1A chr1B chr1D > $INPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}_filtered_chr1.bam

ln -s $INPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}_filtered_chr1.bam $OUTPUT/data/

#bed des isbp de la query (Renan)
# egrep -w 'chr1A|chr1B|chr1D' /home/palasser/results/bwa/isbp_REFSEQV2_vs_RENAN_PSEUDOV2/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2_filtered.bed \
# > /home/palasser/results/bwa/isbp_REFSEQV2_vs_RENAN_PSEUDOV2/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2_filtered_chr1.bed

ln -s /home/palasser/results/bwa/isbp_REFSEQV2_vs_RENAN_PSEUDOV2/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2_filtered_chr1.bed $OUTPUT/data/

#gff des annotations a transferer
#egrep '^chr1' /home/palasser/data/RENAN_v2_pseudo/TaeRenan_refseq_v2.0_genes_updated.gff3 > /home/palasser/data/RENAN_v2_pseudo/TaeRenan_refseq_v2.0_genes_updated_CHR1.gff3
ln -s /home/palasser/data/RENAN_v2_pseudo/TaeRenan_refseq_v2.0_genes_updated_CHR1.gff3 $OUTPUT/data/

#fasta query
#samtools faidx /home/palasser/data/RENAN_v2_pseudo/TaeRenan_refseq_v2.0.fa chr1A chr1B chr1D > /home/palasser/data/RENAN_v2_pseudo/TaeRenan_refseq_v2.0_CHR1.fa
ln -s /home/palasser/data/RENAN_v2_pseudo/TaeRenan_refseq_v2.0_CHR1.fa $OUTPUT/data/

#fasta target
samtools faidx /storage/databanks/bio/ipk/genomes/*${genome}*/ipk_Triticum_*${genome}*/samtools/*.fasta chr1A chr1B chr1D > $OUTPUT/data/Tae${genome}_ipk_CHR1.fasta

#blastdb MRNA de la refseq


