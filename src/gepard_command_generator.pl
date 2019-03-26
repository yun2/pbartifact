#!/usr/bin/perl
use strict;
my $prefix="real";
my $n_fa=62;

for(my $i=0; $i < $n_fa; $i++){
  printf("./gepardcmd.sh -seq1 ../${prefix}_%04d.fa -seq2 ../${prefix}_%04d.fa -matrix ./matrices/edna.mat -outfile ${prefix}_%04d.png\n",$i,$i,$i);
}

