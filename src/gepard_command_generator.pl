#!/usr/bin/perl
use strict;
my $prefix="real";
my $n_fa=62;

for(my $i=0; $i < $n_fa; $i++){
  printf("./gepardcmd.sh -seq1 ../${prefix}_00%02d.fa -seq2 ../${prefix}_00%02d.fa -matrix ./matrices/edna.mat -outfile ${prefix}_00%02d.png\n",$i,$i,$i);
}

