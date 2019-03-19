all: count_shared_kmer

count_shared_kmer: count_shared_kmer.c
	$(CC) -fopenmp -Wall -O3 -o $@ $<

