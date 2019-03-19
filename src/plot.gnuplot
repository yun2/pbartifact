set xlabel "number of shared 24-mer with self reverse complement"
set ylabel "number of the subreads"
set term png
set output "number_of_shared_kmers.png"
plot [0:100][0:100] "ecoli.p6c4.fa.dat" title "real subreads" with linespoints, \
     "depth150_0001.fa.dat" title "simulated subreads" with linespoints


