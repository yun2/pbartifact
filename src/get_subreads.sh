
bax2bam m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.1.bax.h5 -o movie1 --subread
bax2bam m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.2.bax.h5 -o movie2 --subread
bax2bam m141013_011508_sherri_c100709962550000001823135904221533_s1_p0.3.bax.h5 -o movie3 --subread
samtools fastq movie1.subreads.bam > movie1.subreads.fastq
samtools fastq movie2.subreads.bam > movie2.subreads.fastq
samtools fastq movie3.subreads.bam > movie3.subreads.fastq

