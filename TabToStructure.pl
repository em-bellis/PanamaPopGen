#!/usr/bin/perl
use List::Util qw(max);

# -- program description and required arguments
unless ($#ARGV == 1)
        {print "\nReads in a table of SNPs called from E. Meyer's 2bRAD pipeline and converts to a format suitable for input to Structure\n";
	print "Usage:\t TabToStructure.pl in.tab out.txt\n";
        print "\n"; exit;
        }
#-- take in arguments passed from command line, open files for reading and writing
my $infile = $ARGV[0];
my $outfile = $ARGV[1];

print("Input file is ", $infile, "\n");
print("Output file is ", $outfile, "\n");

open(INFILE, "<", $infile) || die ("Can't find the file $infile: $!");
open(OUTFILE, ">", $outfile);

#-- list the ids of each sample in an array and hash
$header = <INFILE>;
chomp($header);
@samples = split(/\t/, $header);
shift(@samples);
shift(@samples);

%sampleGeno=();
@snp_ids = ();

while ($line = <INFILE>) {
#-- name each SNP
	chomp($line);
	$totalLines++;
	@lineParts = split(/\t/, $line);
	$locus = $lineParts[0];	
	$position = $lineParts[1];
	$locPos = $locus."_".$position;
	push @snp_ids, $locPos;

#-- determine reference and alternate allele
	foreach $i(2..$#lineParts) {
		if ($lineParts[$i]=~/[AGCT]/) {
			$catsnps = $catsnps.$lineParts[$i];
		}
	}
	my @Acount = ($catsnps =~ /A/g); my @Gcount = ($catsnps =~ /G/g); my @Ccount = ($catsnps =~ /C/g); my @Tcount = ($catsnps =~ /T/g);
	my @counts = (scalar @Acount, scalar @Gcount, scalar @Ccount, scalar @Tcount);
	$max = max(@counts);
	if ($counts[0] == $max) { $RefAllele = "A";
	} elsif ($counts[1] == $max) { $RefAllele = "G";
	} elsif ($counts[2] == $max) { $RefAllele = "C";
	} elsif ($counts[3] == $max) { $RefAllele = "T";
	}
  	if (($counts[0] < $max) && ($counts[0] > 5))	{ $AltAllele = "A";
        } elsif	(($counts[1] < $max) && ($counts[1] > 5)) { $AltAllele = "G";
        } elsif	(($counts[2] < $max) && ($counts[2] > 5)) { $AltAllele = "C";
        } elsif	(($counts[3] < $max) && ($counts[3] > 5)) { $AltAllele = "T";
        }
	$catsnps = "";

#-- for each snp, code an individual as 0 if they match the ref or 1 if they have an alternate 
	foreach $i(0..$#samples) {
		$currentGeno = $lineParts[$i+2];
		if (($currentGeno =~ /$RefAllele\s+$AltAllele/) || ($currentGeno =~ /$AltAllele\s+$RefAllele/)) {
			$sampleGeno{$samples[$i]}{$locPos}= "het";
		} elsif ($currentGeno eq $RefAllele) {
			$sampleGeno{$samples[$i]}{$locPos}= 0;
		} elsif ($currentGeno eq $AltAllele) {
			$sampleGeno{$samples[$i]}{$locPos}= 1;
		} elsif ($currentGeno == 0) {
                        $sampleGeno{$samples[$i]}{$locPos}= -9;
                }
	}
}

#-- now all the SNP info is stored as a hash of hashed hashes, print in structure format to the outfile

print OUTFILE "\t";
foreach $j(@snp_ids){
	print OUTFILE "\t".$j;
}
print OUTFILE "\n";

foreach $k(@samples){
	if ($k =~ /(BTIC|BTCA|BTCR)/) {
		$popId = $1;			##apparently structure needs the population ids to be integers
		if ($popId eq "BTCA"){ $popId = 1;
		} elsif ($popId eq "BTCR"){ $popId = 2;
		} elsif ($popId eq "BTIC"){ $popId = 3;
		}
	} elsif ($k =~ /CA[PG|IP|IL]/) {
		$popId = 4;
	} else {
		$popId = 5;
	}
	print OUTFILE $k."\t".$popId."\t";
	foreach $j(@snp_ids){
		$isHet = $sampleGeno{$k}{$j};
		if ($isHet eq "het") {
			print OUTFILE "0\t";
		} else {
			print OUTFILE $sampleGeno{$k}{$j}."\t";
		}
	}
	print OUTFILE "\n";
	print OUTFILE $k."\t".$popId."\t";
        foreach	$j(@snp_ids){
	        $isHet = $sampleGeno{$k}{$j};
		if ($isHet eq "het") {
                	print OUTFILE "1\t";
                } else {
	     		print OUTFILE $sampleGeno{$k}{$j}."\t";
		}
        }
	print OUTFILE "\n";
}

close(INFILE);
close(OUTFILE);
