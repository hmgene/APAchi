


## simulation setting 
SIM_RL=50
SIM_BL=6
SIM_AL=5

apa 3pread.sim mRNA.fa $SIM_RL $SIM_BL $SIM_AL > read.fq
apa fastq.trim -5 ".{6}" read.fq \
| apa fastq.trim -5 "T{2}T+" - \
| apa fastq.trim -5 "^.TT+" - > read1.fq

apa hisat2-build genome.fa genome
apa hisat2 -x genome -U read1.fq > read1.sam
apa sam2bam read1.sam read1.bam

apa bedtools bamtobed -bed12 -i read1.bam \
| apa 3pread.filter - genome.fa

apa bedtools bamtobed -bed12 -i read1.bam \
| apa 3pread.filter -n 6 - genome.fa > read1.pa

#
#apa polyafilter.bed2updnseq THAP2_read.bed THAP2_hg19.fa | apa polyafilter.updnseq2fea  -
#apa bed.3p THAP2_read.bed | apa polya.filter -  THAP2_hg19.fa
