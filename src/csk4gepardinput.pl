#!/usr/bin/perl

my $prefix="ecoli.p6c4";
print "count_shared_kmer -k 24 $prefix.fa > $prefix.csk\n";
print "cat $prefix.csk | sort -k1,1nr > $prefix.csk.sorted\n";
print "sharing_kmer_selector.pl -min_hit 75 -max_hit 99 $prefix.csk.sorted | cut -f 2 > $prefix.candidates.list\n";
print "extract_fa.pl $prefix.fa $prefix.candidates.list > $prefix.candidates.fa\n";

#gepard

