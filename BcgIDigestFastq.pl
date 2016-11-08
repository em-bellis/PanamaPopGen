#!/usr/bin/env perl

##Objective: Truncates a set of short reads in FASTQ format to keep only 36 bp regions targeted by BcgI\n"

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
	if ($count==1) {$ss = substr($_, 0, 6);}
	if ($_ =~ /^$ss/) #is the identifier line
		{
		$fastqi{id} = $_;
		next;
		}
	if ($_ =~ /^\+$|^\+SRR/) 
		{
		$fastqi{plus} = "+"; #is the + line
		next;
		}
	else
		{
		$ssi = $_;
		if ($ssi =~ /^[ACTGN]+$/)  #is the line a sequence line?
			{
			if ($ssi =~ /(.{12}CGA.{6}TGC.{12}|.{12}GCA.{6}TCG.{12})/)
				{
				$startpos = $-[0];
				$fastqi{seq} = $1;
				$printme = "Yes";
				}
			else  #it's a seq line, but doesn't have a BcgI cut site
				{
				$printme = "No";
				}
			}
		else   #it's a quality line
			{
			if ($printme eq "Yes")
				{
				$qual = substr($_, $startpos, 36);
				print OUT $fastqi{id}."\n".$fastqi{seq}."\n+\n".$qual."\n";
				}
			}		
		}
	}
close(IN);
close(OUT);
