#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $opt_help=0;
my $opt_strand=0;
my $opt_outfilename="";
my $opt_contig_name_cat_is_file_name=0;
my $opt_prefix_for_contig_names="";
my $opt_out_dir="";
my $opt_force=0;
my $opt_discard_after_space=0;

GetOptions(
  's'=>\$opt_strand,
  'n=s'=>\$opt_outfilename,
  'c'=>\$opt_contig_name_cat_is_file_name,
  'p=s'=>\$opt_prefix_for_contig_names,
  'd=s'=>\$opt_out_dir,
  'f'=>\$opt_force,
  'discard_after_space'=>\$opt_discard_after_space,
  'help'=>\$opt_help
);
my @msgs=(
  "USAGE: <this> <target.fasta> <names.list> [<names.list2> ...]",
  "[-s: regard names.list has strand information]",
  "[-n=s: specify an output file name (default: stdout)]",
  "[-c: a concatenation of contig names is a prefix of the output file name]",
  "[-p=s: prefix for contig names (default: none)]",
  "[-d=s: output directory (default: pwd)]",
  "[-f: ignore not exsisting reads]",
  "[--discard_after_space: use characters before first space as name in '>' line]",
  "[-h: show this message]"
);

if($opt_help){
  my $msg = join("\n\t",@msgs);
  printf STDERR ("%s\n",$msg);
  exit(0);
}

if(@ARGV < 2){
  my $msg = join("\n\t",@msgs);
  printf STDERR ("%s\n",$msg);
  exit(0);
}

my $c_fh;
open $c_fh, "<$ARGV[0]" or die "cannot open $ARGV[0] : $!\n";

if(!$opt_outfilename){
  $opt_outfilename="-";
}

my $name = <$c_fh>;
chomp $name;
$name =~ s/^>//;
if($opt_discard_after_space){
  $name = (split / /,$name)[0];
}
my $bases = "";

my %contigs;

while(1){
  while(my $buf=<$c_fh>){
    chomp $buf;
    if($buf =~ /^>/){
      if(defined($contigs{$name})){
        printf STDOUT ("duplicated contigs: %s\n",$name);
        die "$bases\n";
      }
      $contigs{$name} = $bases;

      $name = $buf;
      $bases= "";
      $name =~ s/^>//;
      if($opt_discard_after_space){
        $name = (split / /,$name)[0];
      }
      last;
    }
    else{
      $bases .= $buf;
    }
  }
  if(eof){
    last;
  }
}
if(defined($contigs{$name})){
  printf STDOUT ("duplicated contigs: %s\n",$name);
  die "$bases\n";
}
$contigs{$name} = $bases;

close $c_fh;

=pod
foreach my $key (sort keys %contigs){
  printf(">%s\n",$key);
  printf("%s\n",$contigs{$key});
}
=cut

for(my $X=1; $X<@ARGV; ++$X){
  my $n_fh;
  open $n_fh, "<$ARGV[$X]" or die "cannot open $ARGV[$X] : $!\n";

  my $outputfilename="";
  
  my $out_fh;
  if($opt_contig_name_cat_is_file_name){
    $outputfilename=`uuidgen`;
    chomp $outputfilename;
    if($opt_out_dir){
      $outputfilename = sprintf("%s/%s",$opt_out_dir,$outputfilename);
    }
    open $out_fh, ">$outputfilename" or die "cannot open $outputfilename: $!\n";
  }
  else{
    open $out_fh, ">$opt_outfilename" or die "cannot open $opt_outfilename: $!\n";
  }

  my @names=();

  while(my $line = <$n_fh>){
    chomp $line;
    if($line =~ /^#/){
      next;
    }
    my $contig_name = $line;
    if($opt_strand){
      my($name,$strand) = split /\s+/,$line;
      $contig_name = $name;
      if($opt_prefix_for_contig_names){
        printf $out_fh (">%s_%s\n",$opt_prefix_for_contig_names,$contig_name);
      }
      else{
        printf $out_fh (">%s\n",$contig_name);
      }
      push @names,$contig_name;
      if($strand eq "+" || $strand eq "f" || $strand eq "fwd"){
        if(defined($contigs{$contig_name})){
          printf $out_fh ("%s\n",$contigs{$contig_name});
        }
        elsif($opt_force){
          printf $out_fh ("NNNNNNNNNNNNNNN\n");
        }
        else{
          die "strange contig: $contig_name\n";
        }
      }
      elsif($strand eq "-" || $strand eq "r" || $strand eq "rev"){
        if(defined($contigs{$contig_name})){
          my $seq = $contigs{$contig_name};
          $seq =~ tr/ACGTacgt/TGCAtgca/;
          $seq = reverse($seq);
          printf $out_fh ("%s\n",$seq);
        }
        elsif($opt_force){
          printf $out_fh ("NNNNNNNNNNNNNNN\n");
        }
        else{
          die "strange contig: $contig_name\n";
        }
      }
    }
    else{
      if($opt_prefix_for_contig_names){
        printf $out_fh (">%s_%s\n",$opt_prefix_for_contig_names,$contig_name);
      }
      else{
        printf $out_fh (">%s\n",$contig_name);
      }
      push @names,$contig_name;
      if(defined($contigs{$contig_name})){
        printf $out_fh ("%s\n",$contigs{$contig_name});
      }
      elsif($opt_force){
        printf $out_fh ("NNNNNNNNNNNNNNN\n");
      }
      else{
        die "strange contig: $contig_name\n";
      }
    }
  }
  close $n_fh;
  close $out_fh;

  if($opt_contig_name_cat_is_file_name){
    my $o_file="";
    if(@names == 0){
      #printf STDERR ("no contig in %s\n",$ARGV[$X]);
    }
    else{
      $o_file = $names[0];
      for(my $i=1; $i<@names && $i<10; ++$i){
        $o_file .= sprintf(",%s",$names[$i]);
      }
    }
    {
      my @tmp = split /\//,$ARGV[$X];
      my $input_file_name = $tmp[$#tmp];
      $o_file = sprintf("%s_%s.fa",$input_file_name,$o_file);
      if($opt_out_dir){
        $o_file = sprintf("%s/%s",$opt_out_dir,$o_file);
      }
    }
    my $retry = 10;
    for(my $i=0; $i<$retry; ++$i){
      my $ret = rename $outputfilename, $o_file;
      if($ret){
        last;
      }
      else{
        if($i+1 == $retry){
          printf STDERR ("ERROR: cannot rename $outputfilename to $o_file: $!\n");
        }
        else{
          sleep 1;
        }
      }
    }
  }
}
