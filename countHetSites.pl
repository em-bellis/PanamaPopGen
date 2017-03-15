#!/usr/bin/perl

##Objective: based on a vcf file, count all the genotyped and heterozygous sites for an individual

my $vcfFile = $ARGV[0];
my $indNumber = $ARGV[1];

open (IN, $vcfFile);

$homSites=0;
$hetSites=0;

while($line = <IN>) {
	chomp($line);
	if ($line =~ /^#CHROM/) {
		@lineParts = split(/\t/,$line);
		$indName = $lineParts[$indNumber];
	} elsif ($line =~ /^scaffold/) {
		@lineParts = split(/\t/,$line);
		$genotype = $lineParts[$indNumber];
		if ($genotype =~ /0\/0|1\/1|2\/2/) {  ##NOTE: output from E. Meyer's gt2vcf.pl script has 1's and 2's instead of 0's and 1's if reference is heterozygous
			$homSites++;
		} elsif ($genotype =~ /0\/1|1\/0|0\/2|2\/0/) {
			$hetSites++;
		}
	}
}

print $indName."\t".$hetSites."\t".$homSites."\n";

close(IN);
