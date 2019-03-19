#!/usr/bin/perl
use strict;
use Getopt::Long;

my $min_hit=1;
my $max_hit=1000000;

GetOptions('min_hit=i' => \$min_hit,
           'max_hit=i' => \$max_hit);
if(@ARGV != 1){
  printf STDERR "USAGE: <this> <in.count_sharing_kmer> [-min_hit=i -max_hit=i]\n";
  exit 1;
}

while(<>){
  chomp;
  my @foo = split /\t/,$_;
  if($foo[0] >= $min_hit and $foo[0] <= $max_hit){
    print "$_\n";
  }
}

