hisat2(){
	$BINARY/hisat2 $@
}

hisat2-build(){
	$BINARY/$FUNCNAME $@
}


sam2bam(){
usage="$FUNCNAME <in.sam> <out.bam>"
if [ $# -lt 2 ];then echo "$usage"; return; fi
        samtools view -h $1 | samtools view -b - \
        | samtools sort - -T $2.tmp > $2
        samtools index $2
}


