#!/bin/bash
#SBATCH --nodes=1 # Un noeud par tache # -N1
#SBATCH --ntasks=1 #-n
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=MUM4A # -J
#SBATCH --partition=fast

module load seqtk 

####################################################################################
# DEFINITION VARIABLES
accession=("REFSEQV1")

####################################################################################
#set up data directories
OUTPUT=$HOME'/results/MUMmer/chr4A'
mkdir -p $OUTPUT
cd $OUTPUT

#seqtk subseq /storage/groups/gdec/shared/triticum_aestivum/chinese_spring/iwgsc/${accession}/fasta/IWGSC_CSRefSeqv1.fasta <(echo "chr4A") > /home/palasser/data/${accession}/IWGSC_CSRefSeqv1_chr4A.fasta

#seqtk subseq /storage/groups/gdec/shared/triticum_aestivum/chinese_spring/iwgsc/REFSEQV2/v2.1/CS_pesudo_v2.1.fa <(echo "Chr4A") > /home/palasser/data/REFSEQV2/CS_pesudo_v2.1_chr4A.fasta

#seqtk subseq /home/palasser/data/RENAN_v2_pseudo/TaeRenan_refseq_v2.0.fa <(echo "chr4A") > /home/palasser/data/RENAN_v2_pseudo/TaeRenan_refseq_v2.0_chr4A.fa

#seqtk subseq <(echo "chr4A") /storage/databanks/bio/ipk/genomes/Triticum_aestivum_Norin61/ipk_Triticum_aestivum_Norin61_2020-4-3/flat/Triticum_aestivum_Norin61_v1.1.pseudomolecules.fasta > $OUTPUT/TaesNorin61_v1.1_chr4A.fasta

####################################################################################
###Alignement region contre region
####################################################################################
module load gcc/8.1.0 MUMmer/4.0.0.beta2
###### REFSEQV2 vs REFSEQV1
nucmer --mum -l 500 -p chr4A_REFSEQV2_vs_${accession} -t 8 /home/palasser/data/${accession}/IWGSC_CSRefSeqv1_chr4A.fasta /home/palasser/data/REFSEQV2/CS_pesudo_v2.1_chr4A.fasta
delta-filter -1 -i 95 $OUTPUT/chr4A_REFSEQV2_vs_${accession}.delta > $OUTPUT/chr4A_REFSEQV2_vs_${accession}_filter.delta

###### Renan vs REFSEQV2
nucmer --mum -l 500 -p chr4A_TaeRenan_refseq_v2.0_vs_REFSEQV2 -t 8 /home/palasser/data/REFSEQV2/CS_pesudo_v2.1_chr4A.fasta /home/palasser/data/RENAN_v2_pseudo/TaeRenan_refseq_v2.0_chr4A.fa
delta-filter -1 -l 10000 -i 95 $OUTPUT/chr4A_TaeRenan_refseq_v2.0_vs_REFSEQV2.delta > $OUTPUT/chr4A_TaeRenan_refseq_v2.0_vs_REFSEQV2_filter.delta

###### Renan vs REFSEQV1
nucmer --mum -l 500 -p chr4A_TaeRenan_refseq_v2.0_vs_${accession} -t 8 /home/palasser/data/${accession}/IWGSC_CSRefSeqv1_chr4A.fasta /home/palasser/data/RENAN_v2_pseudo/TaeRenan_refseq_v2.0_chr4A.fa
delta-filter -1 -l 10000 -i 95 $OUTPUT/chr4A_TaeRenan_refseq_v2.0_vs_${accession}.delta > $OUTPUT/chr4A_TaeRenan_refseq_v2.0_vs_${accession}_filter.delta


##### Norin61 versus REFSEQV2
nucmer --mum -l 500 -p chr4A_TaeNorin61_v1.1_vs_REFSEQV2 -t 8 /home/palasser/data/REFSEQV2/CS_pesudo_v2.1_chr4A.fasta $OUTPUT/TaesNorin61_v1.1_chr4A.fasta
delta-filter -1 -l 10000 -i 95 $OUTPUT/chr4A_TaeNorin61_v1.1_vs_REFSEQV2.delta > $OUTPUT/chr4A_TaeNorin61_v1.1_vs_REFSEQV2_filter.delta


##### A FAIRE EN SE CONNECTANT EN SSH A hpcsmp01
###PLOT Alignement region contre region
module load gcc/4.8.4 MUMmer/3.23 

mummerplot --png -s 'large' -p chr4A_REFSEQV2_vs_${accession} $OUTPUT/chr4A_REFSEQV2_vs_${accession}_filter.delta

mummerplot --png -s 'large' -p chr4A_TaeRenan_refseq_v2.0_vs_REFSEQV2 $OUTPUT/chr4A_TaeRenan_refseq_v2.0_vs_REFSEQV2_filter.delta

mummerplot --png -s 'large' -p chr4A_TaeRenan_refseq_v2.0_vs_${accession} $OUTPUT/chr4A_TaeRenan_refseq_v2.0_vs_${accession}_filter.delta

mummerplot --png -s 'large' -p chr4A_TaeNorin61_v1.1_vs_REFSEQV2 $OUTPUT/chr4A_TaeNorin61_v1.1_vs_REFSEQV2_filter.delta

rm $OUTPUT/chr4A_*.rplot $OUTPUT/chr4A_*.gp $OUTPUT/chr4A_*.fplot