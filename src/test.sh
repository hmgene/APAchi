
test_lineartrend(){
usage="
$FUNCNAME [options] <target.bed> <ctr.bed> <trt.bed> 
  -d <int> : cluster distance (default 10)
  -m <int> : minimum counts per center (default 1)
"
echo $@;
if [ $# -lt  3 ];then echo "$usage";return; fi 
	local OPTARG;local OPTIND;local D=10; local M=1;
	while getopts ":d:m:" opt; do
	  case $opt in
		d) D=$OPTARG;; 
		m) M=$OPTARG;; 
	    	\?) echo "Invalid option: -$OPTARG" >&2;;
	  esac
	done
	shift $(( OPTIND - 1 ));
	echo "chrom start end name score strand positions ctr_counts trt_counts r_corr pvalue" | tr " " "\t"
	apa center -d $D $2 $3 \
	| awk -v M=$M -v OFS="\t" '$5 >= M' \
	| apa bedtools intersect -a $1 -b stdin -s -wa -wb \
	| apa util.groupby - 1,2,3,4,5,6 8,13,14 collapse,collapse,collapse\
	| perl -ne 'chomp;my@a=split/\t/,$_;
		print join("@",@a[0..5]);
		print "\t",join("\t",@a[6..$#a]),"\n";' \
	| apa stat.lineartrend - | tr "@" "\t" 
}
test_lineartrend__test(){
echo \
"c	100	200	gene1	0	-
c	300	400	gene2	0	+" > tmp.3utr

echo \
"c	10	11	pa0	6	-
c	110	111	pa1	5	-
c	120	121	pa2	4	-
c	150	151	pa3	3	-
c	310	311	pa4	2	+
c	399	400	pa5	1	+" > tmp.ctr

echo \
"c	10	11	pa0	10	-
c	110	111	pa1	20	-
c	120	121	pa2	30	-
c	150	151	pa3	40	-
c	310	311	pa4	50	+
c	399	400	pa5	60	+" > tmp.trt
head tmp.*
echo "result:"
apa test_lineartrend -d 1 tmp.3utr tmp.ctr tmp.trt 
rm tmp.*
}
