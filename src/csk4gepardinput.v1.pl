#!/usr/bin/perl

my $prefix="ecoli.p6c4";
print "count_shared_kmer -k 24 $prefix.fa > $prefix.fa.csk\n";
print "cat $prefix.fa.csk | sort -k1,1nr > $prefix.fa.csk.sorted\n";
print "shared_kmer_selector.pl -min_hit 75 -max_hit 99 $prefix.fa.csk.sorted | cut -f 2 > $prefix.fa.candidates.list\n";
print "extract_fa.pl $prefix.fa $prefix.fa.candidates.list > $prefix.fa.candidates.fa\n";

#gepard

