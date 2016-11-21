#!/usr/bin/perl

##read in a table of SNPs called from Meyer lab's 2bRAD pipeline
##filter out SNPs that are not polymorphic in a minimum # of samples.  Heterozygotes are also considered polymorphic (i.e. if three individuals are A/A A/G and G/G, the SNP will pass if $ARGV[1] is 2.)

# -- program description and required arguments
unless ($#ARGV == 2)
        {print "\nReads in a table of SNPs called from e. meyer's 2bRAD pipeline and filters out SNPs that are not polymorphic in a minimum # of samples\n";
	print "Usage:\t MinPolyFilter.pl in.tab 5 out.vcf\n";
        print "Arguments:\n";
        print "\t table\t\t file of SNPs to be filtered, samples in columns, snps in rows\n";
        print "\t minimum number of samples\t SNPs present in fewer individuals than this will be excluded\n";
        print "\t output\t\t a name for the output file (vcf format)\n";
        print "\n"; exit;
        }
#-- take in arguments passed from command line, open files for reading and writing
$infile = $ARGV[0];
$MinIndividuals = $ARGV[1];
$outfile = $ARGV[2];

print("Input file is ", $infile, "\n");
print("Output file is ", $outfile, "\n");

open(INFILE, "<", $infile) || die ("Can't find the file $infile: $!");
open(OUTFILE, ">", $outfile);

#print header lines to the outfile
$header = <INFILE>;
chomp($header);
print OUTFILE $header."\n";

$catsnps = "";

while ($line = <INFILE>) {
	chomp($line);
	$totalLines++;
	@lineParts = split(/\t/, $line);	
	foreach $i(2..$#lineParts) {
		if ($lineParts[$i]=~/[AGCT]/) {
			$catsnps = $catsnps.$lineParts[$i];
		}
	}
	my @Acount = ($catsnps =~ /A/g);
	my @Gcount = ($catsnps =~ /G/g);
	my @Ccount = ($catsnps =~ /C/g);
	my @Tcount = ($catsnps =~ /T/g);
	my @counts = (scalar @Acount, scalar @Gcount, scalar @Ccount, scalar @Tcount);
	foreach $j(0..$#counts) {
		if ($counts[$j] >= $MinIndividuals) {
			$passes++;
		}
	}
	if ($passes >1){
		print OUTFILE $line."\n";
		$passingLines++;
	}
	$passes=0;
	$catsnps="";
}

print $passingLines." SNPs were present in at least ".$MinIndividuals." individuals.\n";
print $totalLines." SNPs total were in the file.\n";

close(INFILE);
close(OUTFILE);
