#!/bin/bash

GFF=$1
LOCI=$2

#######PART 1: get list of loci into easily searchable format 
GENE_ARR=($(cat $LOCI | sed -r 's/_/ /g' | awk '{print $3."_"$4."_"$7."_"$1."_"$2}'))
for i in "${GENE_ARR[@]}"
do
	LOCUS="$i"
	SCAFFOLD=($(echo $LOCUS | sed -r 's/_/ /g' | awk '{print $1}'))
	SEARCHPOS=($(echo $LOCUS | sed -r 's/_/ /g' | awk '{print $2 + $3}'))
	SNP=($(echo $LOCUS | sed -r 's/_/ /g' | awk '{print $4."_"$5}'))

######PART 2: make a list of cds regions for each scaffold from the gff file
	grep "\<$SCAFFOLD\>" $GFF >gene.list
	./SNPinGFF_LD.pl $SEARCHPOS gene.list $SNP 10000
done
