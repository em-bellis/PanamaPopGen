#!/bin/bash

GENES=$1
KEGG=$2

GENE_ARR=($(cat $GENES | awk '{print $1."_"$2}'))
for i in "${GENE_ARR[@]}"
do
	LOCUS="$i"
	GENE=($(echo $LOCUS | sed -r 's/_/ /g' | awk '{print $3}'))
	SNP=($(echo $LOCUS | sed -r 's/_/ /g' | awk '{print $1."_"$2}'))

	printf $SNP"_"; grep "\<$GENE\>" $KEGG
done

