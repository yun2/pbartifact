#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <omp.h>

int K = 24; // kmer's k. K <= 32
//#define FASTQ
#define BUFSIZE 400000
int s_chunk=8192;

char mat[128];
unsigned long long to_code[128];

void chomp(char * s){
  int len = strlen(s);
  (s[len-1] == '\n') ? s[len-1] = '\0' : fprintf(stderr, "strange str %s\nnot end with newline (too long line? > %d)", s,BUFSIZE); // chomp
}

void reversecomplement(char * str){
  int len = strlen(str);
  int loop=len/2;
  int i;
  char tmp;
  for(i=0; i<loop; ++i){
    // swap
    tmp = str[i];
    str[i] = str[len-1-i];
    str[len-1-i] = tmp;
  }
  for(i=0; i<len; ++i){
    str[i] = mat[(int)str[i]];
  }
}

unsigned long long ntuple_code(const char * str, int stt, int n){
  if(n>32){
    fprintf(stderr, "nruplw_code: cannot handle %d(>32)-mer\n",n);
    exit(1);
  }
  unsigned long long ret=0;
  int i;
  for(i=0; i<n; ++i){
    ret |= (to_code[(int)str[stt+i]] << (2*(n-i-1)));
  }
  return ret;
}

double gettimeofday_sec(){
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return tv.tv_sec + tv.tv_usec * 1e-6;
}

void read2kmerpop(char * read, unsigned long long * bucket);
void p_num_of_sharing_kmers(char **, char **, unsigned long long **, unsigned long long **, int*, int);
int compare_ull(const void *a, const void *b);

int opt_fastq=0;
int opt_type=0;

int main(int argc, char * argv[]){
  mat[(int)'A'] = 'T';
  mat[(int)'a'] = 'T';
  mat[(int)'C'] = 'G';
  mat[(int)'c'] = 'G';
  mat[(int)'G'] = 'C';
  mat[(int)'g'] = 'C';
  mat[(int)'T'] = 'A';
  mat[(int)'t'] = 'A';
  mat[(int)'N'] = 'N';
  mat[(int)'n'] = 'N';
  to_code[(int)'A'] = 0ull;
  to_code[(int)'a'] = 0ull;
  to_code[(int)'C'] = 1ull;
  to_code[(int)'c'] = 1ull;
  to_code[(int)'G'] = 2ull;
  to_code[(int)'g'] = 2ull;
  to_code[(int)'T'] = 3ull;
  to_code[(int)'t'] = 3ull;
  to_code[(int)'N'] = 0ull;// XXX
  to_code[(int)'n'] = 0ull;

  int hitnum=0;
  {
    int result;
    while((result=getopt(argc,argv,"k:qt")) != -1){
      switch(result){
        case 'k':
          K=atoi(optarg);
          if(K > 32 || K < 1){
            fprintf(stderr, "K must be 1 <= K <= 32.\n");
            return 1;
          }
          hitnum+=2;
          break;
        case 'q':
          opt_fastq=1;
          ++hitnum;
          break;
        case 't':
          opt_type=1;
          ++hitnum;
          break;
        case '?':
          printf("humei\n");
          break;
        default:
          break;
      }
    }
  }

  if(argc != 2+hitnum){
    fprintf(stderr, "USAGE: <this> <in.fa>\n");
    fprintf(stderr, "\t-k=i: kmer's k (<=32)\n");
    fprintf(stderr, "\t-t: count the number of types of shared kmers, not freq\n");
    return 1;
  }

  char * in_fa = argv[1+hitnum];

  FILE * fp = fopen(in_fa,"r");
  if(fp == NULL){
    fprintf(stderr, "cannot open %s\n", in_fa);
    exit(1);
  }
  char **reads = (char**)malloc(sizeof(char*)*s_chunk);
  if(reads == NULL){
    fprintf(stderr,"cannot allocate memory: reads\n");
    exit(1);
  }
  {
    int i;
    for(i=0; i<s_chunk; ++i){
      reads[i] = (char*)malloc(sizeof(char)*BUFSIZE);
      if(reads[i] == NULL){
        fprintf(stderr,"cannot allocate memory: reads[%d]\n",i);
        exit(1);
      }
    }
  }

  char **nls = (char**)malloc(sizeof(char*)*s_chunk);//namelines
  if(nls == NULL){
    fprintf(stderr,"cannot allocate memory: nls\n");
    exit(1);
  }
  {
    int i;
    for(i=0; i<s_chunk; ++i){
      nls[i] = (char*)malloc(sizeof(char)*BUFSIZE);
      if(nls[i] == NULL){
        fprintf(stderr,"cannot allocate memory: nls[%d]\n",i);
        exit(1);
      }
    }
  }

  char *dum = (char*)malloc(sizeof(char)*BUFSIZE);
  if(dum == NULL){
    fprintf(stderr,"cannot allocate memory: dum\n");
    exit(1);
  }

  unsigned long long ** buckets = (unsigned long long**)malloc(sizeof(unsigned long long*)*s_chunk);
  if(buckets == NULL){
    fprintf(stderr, "cannot allocate memory: buckets\n");
    exit(1);
  }
  {
    int i;
    for(i=0; i<s_chunk; ++i){
      buckets[i] = (unsigned long long*)malloc(sizeof(unsigned long long)*BUFSIZE);
      if(buckets[i] == NULL){
        fprintf(stderr,"cannot allocate memory: buckets[%d]\n",i);
        exit(1);
      }
    }
  }
  unsigned long long ** b2 = (unsigned long long**)malloc(sizeof(unsigned long long*)*s_chunk);
  if(b2 == NULL){
    fprintf(stderr, "cannot allocate memory: b2\n");
    exit(1);
  }
  {
    int i;
    for(i=0; i<s_chunk; ++i){
      b2[i] = (unsigned long long*)malloc(sizeof(unsigned long long)*BUFSIZE);
      if(b2[i] == NULL){
        fprintf(stderr,"cannot allocate memory: b2[%d]\n",i);
        exit(1);
      }
    }
  }

  int * n_share = (int*)malloc(sizeof(int)*s_chunk);
  if(n_share == NULL){
    fprintf(stderr,"cannot allocate memory: n_share\n");
    exit(1);
  }

  int n_read=0;
  while(fgets(nls[n_read],BUFSIZE,fp)!=NULL){
    chomp(nls[n_read]);
    fgets(reads[n_read],BUFSIZE,fp);
    chomp(reads[n_read]);
    if(opt_fastq){
      fgets(dum,BUFSIZE,fp);// opt
      fgets(dum,BUFSIZE,fp);// qvs
    }
    if(strlen(reads[n_read]) < K){
      continue;
    }
    else{
      ++n_read;
    }
    if(n_read<s_chunk){
      continue;
    }

    p_num_of_sharing_kmers(reads,nls,buckets,b2,n_share,n_read);
    n_read=0;
  }
  p_num_of_sharing_kmers(reads,nls,buckets,b2,n_share,n_read);

  fclose(fp);

  {
    int i;
    for(i=0; i<s_chunk; ++i){
      free(reads[i]);
    }
  }
  free(reads);
  {
    int i;
    for(i=0; i<s_chunk; ++i){
      free(nls[i]);
    }
  }
  free(nls);
  free(dum);
  {
    int i;
    for(i=0; i<s_chunk; ++i){
      free(buckets[i]);
    }
  }
  free(buckets);
  {
    int i;
    for(i=0; i<s_chunk; ++i){
      free(b2[i]);
    }
  }
  free(b2);
  free(n_share);
  return 0;
}

void read2kmerpop(char * read, unsigned long long * bucket){

  unsigned long long kalph = ntuple_code(read,0,K);
  bucket[0] = kalph;

  unsigned long long mask=1ull;
  if(K<32){
    mask<<=2*K;
    mask -= 1ull;
  }
  else{
    mask = 0xffffffffffffffffull;
  }
  int imax = strlen(read)-K;
  int i;
  for(i=1; i<= imax; ++i){
    kalph <<= 2;
    kalph &= mask;
    kalph |= to_code[(int)read[K-1+i]];
    bucket[i] = kalph;
  }

  /*
  for(i=0; i<count; ++i){
    if(bucket[i] > 0){
      fprintf(stdout, "%d\t%d\n", i, bucket[i]);
    }
  }
  fprintf(stdout, "%d\t%d\n", INT_MAX, INT_MAX);// as a separator
  */
  return;
}

void p_num_of_sharing_kmers(char ** reads, char ** nls, unsigned long long ** buckets, unsigned long long ** b2, int * n_share, int n_reads){
  int i;
  #pragma omp parallel for
  for(i=0; i<n_reads; ++i){
//    printf("%s\n",read);
//    double stt,end;
//    stt=gettimeofday_sec();
    read2kmerpop(reads[i], buckets[i]);
//    end=gettimeofday_sec();
//    fprintf(stderr,"read2kmerpop_1: %f\n",end-stt);
    reversecomplement(reads[i]);
//    printf("%s\n",read);
//    stt=gettimeofday_sec();
    read2kmerpop(reads[i], b2[i]);
//    end=gettimeofday_sec();
//    fprintf(stderr,"read2kmerpop_2: %f\n",end-stt);
//    stt=gettimeofday_sec();
    int j,k;
    int loop = strlen(reads[i])-K+1;
    n_share[i]=0;
    qsort(buckets[i], loop, sizeof(unsigned long long), compare_ull);
    qsort(b2[i], loop, sizeof(unsigned long long), compare_ull);
    /*
    for(j=0; j<loop;++j){
      printf("%llu,",buckets[i][j]);
    }
    printf("\n");
    for(j=0; j<loop;++j){
      printf("%llu,",b2[i][j]);
    }
    printf("\n");
    */
    for(j=0,k=0; j<loop && k<loop;){
      if(buckets[i][j] < b2[i][k]){
        ++j;
      }
      else if(buckets[i][j] > b2[i][k]){
        ++k;
      }
      else{
        ++n_share[i];
        ++j;
        ++k;
        if(opt_type){
          while(j<loop && buckets[i][j] == buckets[i][j-1]){
            ++j;
          }
          while(k<loop && b2[i][k] == b2[i][k-1]){
            ++k;
          }
        }
      }
    }
    printf("%d\t%s\n",n_share[i],&nls[i][1]);
//    end=gettimeofday_sec();
//    fprintf(stderr,"kmercount: %f\n",end-stt);
  }
}

int compare_ull(const void *a, const void *b){
    unsigned long long foo = *(unsigned long long*)a;
    unsigned long long bar = *(unsigned long long*)b;
//    printf("%llu\n",foo);
//    printf("%llu\n",bar);
    if(foo<bar){
      return -1;
    }
    else if(foo==bar){
      return 0;
    }
    else{
      return 1;
    }
}
