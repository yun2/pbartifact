#!/usr/bin/perl
use strict;

while(<>){
  chomp;
  my @uniq_c_out = split /\s+/, $_;
  #print "$uniq_c_out[0]\n";
  #print "$uniq_c_out[1]\t$uniq_c_out[2]\n";
  print "$uniq_c_out[2]\t$uniq_c_out[1]\n";
  #print "$uniq_c_out[2]\n";
}
