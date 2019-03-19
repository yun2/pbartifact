#!/usr/bin/perl
use strict;

#my $prefix="ecoli.p6c4";
my $prefix="depth150_0001";
print "fq2fa.pl $prefix.fastq > $prefix.fa\n";
print "count_shared_kmer -k 24 $prefix.fa > $prefix.fa.csk\n";
print "sort -k1,1n $prefix.fa.csk > $prefix.fa.csk.sorted\n";
print "cut -f 1 $prefix.fa.csk.sorted | uniq -c | rev_uniq-c.pl > $prefix.fa.dat\n";

#gnuplot

