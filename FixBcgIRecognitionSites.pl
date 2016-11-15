#!/usr/bin/env perl

##Objective: This script will 'mask' bases at BcgI recognition site.  Bases must match at positions 13 and 14 or 13 and 24, or the entire sequence will be masked with 'N'\n"

my $seqfile = $ARGV[0];		# raw reads, fastq format
my $outfile = $ARGV[1];		# name for output file, fastq format

# loop through fastq file and truncate sequences and quality scores
open (IN, $seqfile);
open (OUT, ">$outfile");
my %fastqi;
while(<IN>)
	{
	chomp;
	$count++;
	if ($count==1) {$ss = substr($_, 0, 5);}
	if ($_ =~ /^$ss/) #is the identifier line
		{
		print OUT $_."\n";
		next;
		}
	if ($_ =~ /^\+$/) 
		{
		print OUT $_."\n";
		next;
		}
	else
		{
		$ssi = $_;
		if ($ssi =~ /^[ACTGN]+$/)  #is the line a sequence line?
			{
			if ($ssi =~ /(\w{12})CG\w{1}(\w{6})\w{3}(\w{12})|(\w{12})C\w{2}(\w{6})\w{2}C(\w{12})/)
				{
				print OUT $1.CGA.$2.TGC.$3."\n";
				$matchedLines1++;
				}
			elsif ($ssi =~ /(\w{12})GC\w{1}(\w{6})\w{3}(\w{12})|(\w{12})G\w{2}(\w{6})\w{2}G(\w{12})/)
				{
				print OUT $1.GCT.$2.ACG.$3."\n";
				$matchedLines2++;
				}
			else 
				{
				print OUT "NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\n";
				$unmatchedLines++;
				#print $_."\n";
				}
			}
		else   #it's a quality line
			{
			print OUT $_."\n";
			}
		}		
	}

print $matchedLines1." sequences matched recognition site CGANNNNNNTGC.\n";
print $matchedLines2." sequences matched recognition site GCTNNNNNNACG.\n";
print $unmatchedLines." sequences did not match either recognition site at positions 13 and 14 or 13 and 24.\n"; 
close(IN);
close(OUT);
