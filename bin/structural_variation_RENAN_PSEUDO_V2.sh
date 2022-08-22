#!/bin/bash

OUTPUT='/home/palasser/results/bwa/isbp_REFSEQV2_vs_RENAN_PSEUDOV2'

##inversions
rm $OUTPUT/structural_variation_TaeRenan_refseq_v2.0_2Mb.bed
for chr in "1A" "1B" "1D" "2A" "2B" "2D" "3A" "3B" "3D" "4A" "4B" "4D" "5A" "5B" "5D" "6A" "6B" "6D" "7A" "7B" "7D";
do
    ##paste de fin inversion = passage de strand - a strand + (on garde le strand ("-"") et les coordonnees de ligne before)
    ##et de debut inversion = passage de + a - 
    ##selection des lignes avec info de fin et debut
    ##skip premiere ligne si commence par une "fin" d'inversion
    ##bed inversions structurales par rapport a REFSEQV2 avec taille > 
    paste <(grep $chr $OUTPUT/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2_filtered.bed \
    |gawk -v OFS="\t" 'NR!=1 {strand_before=a[6]; start_before=a[2]; end_before=a[3]} {split($0,a,FS)} { if ($6=="+" && strand_before=="-") {print $0,$1,start_before,end_before,strand_before} else print $0}') \
    <(grep $chr $OUTPUT/ISBPS_REFSEQV2_vs_RENAN_PSEUDOV2_filtered.bed |awk 'f{print $0;f=0} /chr/{f=1}') \
    |gawk -vOFS='\t' '{ if ($10=="-") {print "end",$7,$8,$9}; if ($6=="+" && $12=="-") {print "start",$7,$8,$9}; if ($6=="+" && $16=="-") {print "start",$11,$12,$13}}' \
    |gawk -vOFS='\t' '{ if (NR==1 && $1!="end") print $0; if (NR!=1) print $0 }' \
    |gawk -v OFS="\t" 'NR!=1 {start_before=a[3]} {split($0,a,FS)} { if ($1=="end" && $4-start_before>2000000) print $2,start_before,$4,$4-start_before }' \
    >> $OUTPUT/structural_variation_TaeRenan_refseq_v2.0_2Mb.bed
done

##translocation
fgrep chr4A ISBPS_REFSEQV2_RENAN_PSEUDOV2_input_dotplot.txt |gawk '{if ($3>220000000 && $3<380000000 && $5>245000000 && $5<330000000) print $0}' \
|gawk -v OFS="\t" 'NR!=1 {start_before=a[5]} {split($0,a,FS)} {print $0,$5-start_before}' |more