#!/bin/bash
#SBATCH --nodes=1 # Un noeud par tache
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=bwaIsbp
#SBATCH --partition=debug
#SBATCH --array=0-9

####################################################################################
# DEFINITION VARIABLES
####################################################################################
genomes=("arianaLrFor" "CDC_Landmark" "CDC_Stanley" "Jagger" "Julius" "LongReach_Lancer" "Mace" "Norin61" "SY_Mattis" "spelta")
genome=${genomes[$SLURM_ARRAY_TASK_ID]}

BWA_INDEX=$(echo /storage/databanks/bio/ipk/genomes/*${genome}*/ipk_Triticum_*${genome}*/bwa/all.amb |sed 's/\.amb//')

INPUT='/home/palasser/data/RENAN_v2_pseudo/'
OUTPUT='/home/palasser/results/bwa/isbp_RENAN_PSEUDOV2_vs_10GENOMES'

mkdir $OUTPUT

####################################################################################
## FASTA ISBPs RENAN_PSEUDOV2 (issus d'un alignmt bwa des isbp REFSEQV2, 2 mismatch, cov 100%, mapq30)
## source isbp: /storage/groups/gdec/shared/triticum_aestivum/chinese_spring/iwgsc/REFSEQV2/v2.1/annotation/ISBPs/Tae.Chinese_Spring.refSeqv2.1.ISBPs.bed
####################################################################################
# ml gcc/4.8.4 bedtools

# ##fastaFromBed=bedtools getfasta
# fastaFromBed -name -fi $INPUT/TaeRenan_refseq_v2.0.fa \
# -bed /home/palasser/results/bwa/isbp_REFSEQV2_vs_RENAN_PSEUDOV2/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2_filtered.bed \
# -fo $INPUT/TaeRenan_refseq_v2.0.ISBPs.fasta

####################################################################################
# BWA
####################################################################################
ml gcc/8.1.0 samtools/1.9 bwa/0.7.17

echo "isbp bwa alignment on ${genome}"

bwa mem -t $SLURM_CPUS_PER_TASK $BWA_INDEX $INPUT/TaeRenan_refseq_v2.0.ISBPs.fasta \
|samtools view -bS - |samtools sort -o $OUTPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}.bam

####################################################################################
# Filtre du resultat de BWA
####################################################################################
ml python/3.7.1 pysam/0.15.3

## RAPPEL: bwa met une mapQ0 pour les multi best hit (meme score d'alignement sur plusieurs loci); mapQ30 => 1/1000 chance que l'alignement soit faut
## OPTIONS de filterBWA.py: minMappingQuality 30, maxMissmatches 2, minCoverage 1 (100%), maxSoftClippedBases 0, maxHardClippedBases 0
filterBWA.py $OUTPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}.bam $OUTPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}_filtered.bam 30 2 1 0 0 2> $OUTPUT/filterBWA_${genome}.log

ml gcc/4.8.4 bedtools
bedtools bamtobed -i $OUTPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}_filtered.bam > $OUTPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}_filtered.bed

####################################################################################
# Mise en forme pour dotplots avec R
####################################################################################
join -t$'\t' -1 3 -2 3 <(cut -f1,2,4 /home/palasser/results/bwa/isbp_REFSEQV2_vs_RENAN_PSEUDOV2/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2_filtered.bed |sort -k3,3) \
<(cut -f1,2,4 $OUTPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}_filtered.bed |sort -k3,3) |sort -k2,2 -k3,3n \
|gawk '{ if ($2==$4) print $0 }' > $OUTPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}_input_dotplot.txt

rm $OUTPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}.bam $OUTPUT/ISBPS_RENAN_PSEUDOV2_vs_${genome}_filtered.bam_summary.csv