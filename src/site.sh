site(){
usage="
$FUNCNAME <bam> [regions ..]
"
if [ $# -lt 1 ];then echo "$usage"; return; fi
	apa samtools view -bq 10 $1 ${@:2} \
	| apa bedtools bamtobed \
	| awk -v OFS="\t" '{
		$4="."; $5=1;
		if($6=="-"){ $6="+"; $2=$3-1;
		}else{ $6="-"; $3=$2+1; }
		print $0;
	}' | apa util.groupby - 1,2,3,4,6 5 sum \
	| awk -v OFS="\t" '{ print $1,$2,$3,$4,$6,$5;}'
}

center(){
usage="
$FUNCNAME [options] <bed> [<bed> .. ] 
 [options]:
	 -d <value> : bin size (default 10)
"
	local OPTARG;local OPTIND;local D=10;
	while getopts ":d:" opt; do
	  case $opt in d)
	      D=$OPTARG;; 
	    \?) echo "Invalid option: -$OPTARG" >&2;;
	  esac
	done
	shift $(( OPTIND - 1 ));
	if [ $# -lt 2 ];then echo "$usage"; return; fi

	perl -e 'use strict;
	my $fid=0;
	foreach my $f (@ARGV){
		open(my $fh,"<",$f) or die "$! $f";
		while(<$fh>){chomp;my @a=split/\t/,$_;
			$a[3]=$fid;
			if($a[4] == 0){ $a[4]=1;} ## count zeros
			print join("\t",@a),"\n";
		}
		close($fh);
		$fid++;
	}
	' $@ | apa bedtools cluster -i stdin -d $D -s \
	| perl -e 'use strict; my $N='$#';
		sub wpos{
			my ($d,$N)=@_;
			if(scalar @$d == 0){ return;}
			my $xsum=0; my $ysum=0; my $zsum=0; my $n=0;
			my %y=();
			my @a0=split/\t/,$d->[0];
			map{ my @a=split /\t/,$_;
				$xsum += $a[1];
				$ysum += $a[4];
				$zsum += $a[1] * $a[4];
				$n ++;
				$y{ $a[3] } += $a[4];
			} @$d;
			my $p=int( $zsum/$ysum + 0.5);
			print join("\t",( $a0[0],$p,$p+1,"c",$ysum,$a0[5]));
			map{
				my $v=$y{$_}; $v=0 if ! defined $v;
				print "\t$v";
			} 0..($N-1);
			print "\n";
		}
		my @D=(); my $cid=0;
		while(<STDIN>){chomp;my@a=split/\t/,$_;
			if($cid != $a[6]){
				wpos(\@D,$N);	
				$cid=$a[6]; @D=();
			}
			push @D,$_;	
		}
		wpos(\@D,$N);
	'
}

center__test(){
echo \
"chr1	2	3	r1	0	+
chr1	5	6	r3	4	+
chr1	1	2	r1	2	+
chr1	1	2	r2	3	-
chr2	5	6	r4	5	+" > tmp.a

echo \
"chr1	2	3	r1	0	+
chr1	1	2	r1	2	+
chr1	1	2	r2	3	-
chr1	5	6	r3	4	+" > tmp.b
	echo "d=2"
	center -d 2 tmp.a tmp.b
	echo "d=1"
	center -d 1 tmp.a tmp.b
	rm tmp.a tmp.b
}
