apa hisat2 build THAP2_hg19.fa THAP2_hg19
apa hisat2 -x THAP2_hg19 -f -U THAP2_read.fa > THAP2_read.sam
apa samtools view -b THAP2_read.sam | apa bedtools bamtobed > THAP2_read.bed
apa polyafilter.bed2updnseq THAP2_read.bed THAP2_hg19.fa | apa polyafilter.updnseq2fea  -
apa bed.3p THAP2_read.bed | apa polya.filter -  THAP2_hg19.fa
## 100bp + 6 random + 10 A
apa sim.3readp THAP2_mRNA.fa 100 6 10 > THAP2_3readp_read.fq

