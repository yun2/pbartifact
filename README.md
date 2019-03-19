## Introduction

![Image](number_of_shared_kmers.png "fig.1")

fig.1

We plotted the number of shared 24-mers between the subread and
its reverse complementary subread of E. coli of p6c4 chemistry.

The real data have a long tail.
But the simulated data don't.

Why?

## dot plot with itself

We extracted the subreads having many number of shared k-mer (24-mer)
and made dotplots with itself using [gepard](http://cube.univie.ac.at/gepard).

![Image](real_0003.png "fig.2")

fig.2

![Image](real_0007.png "fig.3")

fig.3

![Image](real_0049.png "fig.4")

fig.4

In fig.2 we think that one adapter was ignored and the other was trimmed.

In fig.3 we think that one adapter was ignored and reading was stopped halfway.

In fig.4 we think both adapters were ignored.

We named this type of artifact "x-type artifact".

## Discussion

De novo assembly may be simpler if x-type artifact is removed.

Resequencing will be less affected if high coverage subreads are used.

## Methods

#preparation

```sh
git clone git@bitbucket.org:yun2/pbartifact.git
cd pbartifact/src
make
chmod u+x *.pl
```

Then add a path to pbartifact/src to $PATH .

Install [samtools](https://github.com/samtools/samtools)
, [bax2bam](https://github.com/PacificBiosciences/bax2bam)
, [pbsim](https://github.com/pfaucon/PBSIM-PacBio-Simulator)
and [gepard](http://cube.univie.ac.at/gepard).

Download E. coli data from [here](https://github.com/PacificBiosciences/DevNet/wiki/E.-coli-Bacterial-Assembly).

```sh
wget https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-P6C4/p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz
tar xvzf p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz
```

Then use src/get_subreads.sh

```sh
cd E01_1/Analysis_Results/
cp ../../src/get_subreads.sh .
bash get_subreads.sh
cat movie*.subreads.fastq > ecoli.p6c4.fastq
cd ../../
ln -s E01_1/Analysis_Results/ecoli.p6c4.fastq .
```

#pbsim
```sh
fq2fa.pl polished_assembly.fastq > polished_assembly.fa
pbsim.procedure.pl | bash
```

#gnuplot
open src/csk4gnuplot.pl and edit:
```sh
#my $prefix="ecoli.p6c4";
my $prefix="depth150_0001";
```
then
```sh
src/csk4gnuplot.pl | bash
```

open src/csk4gnuplot.pl and edit:
```sh
my $prefix="ecoli.p6c4";
#my $prefix="depth150_0001";
```
then
```sh
src/csk4gnuplot.pl | bash
```

Then
```sh
gnuplot src/plot.gnuplot
```

#dotplot real subreads using gepard
```sh
src/csk4gepardinput.pl
# count the number of records:
wc -l ecoli.p6c4.candidates.list

mkdir dot
cd dot
partition_fa.pl ../ecoli.p6c4.candidates.fa <number_of_records_described_above> -p real
wget http://cube.univie.ac.at/sites/cub/files/gepard/gepard-1.30.zip
unzip gepard-1.30.zip
cd gepard-1.30
cp ../../src/gepard_command_generator.pl .
#edit gepard_command_generator.pl and
./gepard_command_generator.pl > tmp.sh
#check tmp.sh and
bash tmp.sh
#you will get dotplots like fig.2-4 (but not all are x-type artifacts).
```

