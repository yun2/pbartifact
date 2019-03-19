#!/usr/bin/perl
use strict;

my $prefix="ecoli.p6c4";
#print "ln -s /path/to/ecoli.p6c4/subreads.fq $prefix.fq\n";
#print "fq2fa.pl polished_assembly.fastq > polished_assembly.fa\n";
print "pbsim --depth 150 --prefix depth150 --length-max 65000 --data-type CLR --seed 1 --sample-fastq $prefix.fastq polished_assembly.fa --accuracy-min 0.0\n";

