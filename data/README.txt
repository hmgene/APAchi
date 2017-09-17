


## simulation setting 
SIM_RL=50
SIM_BL=6
SIM_AL=5

apa sim.3readp mRNA.fa $SIM_RL $SIM_BL $SIM_AL > read.fq
apa trim -5 ".{6}" read.fq | apa trim -5 "T{2}T+" - > read1.fq

apa hisat2-build genome.fa genome
apa hisat2 -x genome -U read.fq > read.sam
apa hisat2 -x genome -U read1.fq > read1.sam

apa samtools view -b read1.1.sam | apa bedtools bamtobed -bed12 | apa 3readp.filter - genome.fa
#
#apa polyafilter.bed2updnseq THAP2_read.bed THAP2_hg19.fa | apa polyafilter.updnseq2fea  -
#apa bed.3p THAP2_read.bed | apa polya.filter -  THAP2_hg19.fa
