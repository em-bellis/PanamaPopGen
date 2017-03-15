#!/bin/bash

#wrapper to run countHetSites.pl for all individuals represented in a vcf file

rm -rf test.out
for i in `seq 9 170`;
do
	./countHetSites.pl test.vcf $i >>test.out
done
