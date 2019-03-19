## Introduction

![Image](number_of_shared_kmers.png "rs")

fig.1

We plotted the number of shared 24-mers between the subread and its reverse complementary subread.
The real data have a long tail.
But the simulated data don't.

Why?

## dot plot with itself

We extracted the subreads having many number of shared k-mer (24-mer)
and made dotplots with itself using [gepard](http://cube.univie.ac.at/gepard).

![Image](real_0003.png "xt")

fig.2

![Image](real_0007.png "xt")

fig.3

![Image](real_0049.png "xt")

fig.4

In fig.2 we think that one adapter was ignored and the other was trimmed.

In fig.3 we think that one adapter was ignored and reading was stopped halfway.

In fig.4 we think both adapters were ignored.

We named this type of artifact "x-type artifacts".



