#!/usr/bin/perl
use List::Util qw[min max];

##will check a gff file to see if the input snps occur in the region given the position of the snp in the scaffold

#-- take in arguments passed from command line, open files for reading and writing
$position = $ARGV[0];
$gffFile = $ARGV[1];
$snpName = $ARGV[2];
$decayWindow = $ARGV[3];

open(INFILE, "<", $gffFile) || die ("Can't find the file $gffFile: $!");

$prevPos = 0;
$prevPos2 = 0;

while ($line = <INFILE>) {
	chomp($line);
	@lineParts = split(/\s+/, $line);
	if ($lineParts[3] != $prevPos && $lineParts[4] != $prevPos2) {  ##ignore locus if it starts or ends in same position but annotated with different gene name
		$minPos = max($position - $decayWindow, 0);
		$maxPos = $position + $decayWindow;
		if ($lineParts[3] >= $minPos && $lineParts[4] <= $maxPos) {
			print $snpName."\t".$position."\t".$line."\n";
			$prevPos = $lineParts[3];
			$prevPos2 = $lineParts[4];
		}
	}
}

close(INFILE);
