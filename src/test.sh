
test_lineartrend(){
usage="
$FUNCNAME <target.bed> <ctr.bed> <trt.bed> [<clusterd>]
  [<clusterd>] : cluster distance (default 10)
"
echo $@;
if [ $# -lt  3 ];then echo "$usage";return; fi 
	local clusterd=${4:-10};
	echo "chrom start end name score strand positions ctr_counts trt_counts r_corr pvalue" | tr " " "\t"
	apa center -d $clusterd $2 $3 \
	| apa bedtools intersect -a $1 -b stdin -s -wa -wb \
	| util.groupby - 1,2,3,4,5,6 8,13,14 collapse,collapse,collapse\
	| perl -ne 'chomp;my@a=split/\t/,$_;
		print join("@",@a[0..5]);
		print "\t",join("\t",@a[6..$#a]),"\n";' \
	| stat.lineartrend - | tr "@" "\t" 
}
test_lineartrend.test(){
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
apa test_lineartrend tmp.3utr tmp.ctr tmp.trt  1
rm tmp.*
}
