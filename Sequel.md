## dot plot with itself

CLRs of Sequel II may have the same type of artifact.

See the images below.

![Image](./img/sequelIIclr_0079.png "fig.1")

fig.1

![Image](./img/sequelIIclr_0071.png "fig.2")

fig.2

![Image](./img/71and79/0079-1.png "fig.3")
![Image](./img/71and79/0079-2.png "fig.4")
![Image](./img/71and79/0079-3.png "fig.5")

fig.3-5

The CLR of fig.1 was aligned to the genome (hs37d5.fa) by minimap2

But it was not aligned end-to-end

![Image](./img/71and79/0071-1.png "fig.6")
![Image](./img/71and79/0071-2.png "fig.7")
![Image](./img/71and79/0071-3.png "fig.8")

fig.6-8

The CLR of fig.2 was aligned to the genome (hs37d5.fa) by minimap2

But it was not aligned end-to-end

## Methods

###data preparation
```sh
wget https://downloads.pacbcloud.com/public/dataset/SV-HG002-CLR/hs37d5.HG002-SequelII-CLR.bam
wget https://downloads.pacbcloud.com/public/dataset/SV-HG002-CLR/hs37d5.HG002-SequelII-CLR.bam.bai
samtools fasta hs37d5.HG002-SequelII-CLR.bam > hs37d5.HG002-SequelII-CLR.fasta
ln -s hs37d5.HG002-SequelII-CLR.fasta sequelIIclr.fa
```

###dotplot real subreads using gepard
```sh
src/csk4gepardinput.pl | bash
head -200 sequelIIclr.fa.candidates.fa > 100.fa

mkdir dot
cd dot
partition_fa.pl ../100.fa 100 -p sequelIIclr
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

###alignment

```sh
minimap2 -x map-pb -d hs37d5.mmi hs37d5.fa
minimap2 -ax map-pb hs37d5.mmi <part_of_candidates.fa> > output.sam
```

##contact
sprai2017 at gmail dot com

(Takamasa Imai)

