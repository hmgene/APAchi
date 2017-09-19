
3pread.sim(){
usage="$FUNCNAME <mRNA.fasta> <read.len> <randombarcode.len> <a.len>"
if [ $# -lt 4 ];then echo "$usage"; return; fi
cat $1 | perl -e 'use strict;
	our $RL='$2';
	our $BL='$3';
	our $AL='$4';
	sub f{
		my ($id,$seq)=@_;
		if($seq ne ""){
			my $read=substr($seq,- $RL);
			my $barcode="A" x $AL; 
			map{ $barcode .= substr("ACGT", int(rand(4)),1); } 1..$BL; 
			#print $id," ",$seq,"\n";
			$read .= $barcode;
			$read=~tr/ACGTacgt/TGCAtgca/;
			$read=reverse($read);
			print "@","$id\n";
			print uc $read,"\n";
			print "+\n";
			print "I" x length($read),"\n";
		}
	}
	my $id="";
	my $seq="";
	while(<STDIN>){ chomp; 
		if($_=~/^>/){ 
			f($id,$seq);
			$id=substr($_,1);
			$seq="";
		}else{
			$seq .= $_;
		}
	}
	f($id,$seq);

'

}
3pread.filter(){
usage="
$FUNCNAME [options] <bed> <fasta> 
[options]:
	-n=<num> : length of 5\' random barcode (default 0)
"
local OPTARG; local OPTIND;
local N=0;
while getopts ":n:" opt; do
	case $opt in
		n) N=$OPTARG;;
		?) echo "$usage";return;;
	esac
done
shift $(( OPTIND-1 ))
if [ $# -lt 2 ];then echo "$usage"; return; fi
cat $1 | perl -ne 'my $N='$N';chomp; my @a=split/\t/,$_; 
	my $R="";
	my $T="";
	my $RT="";
	if($a[3]=~/:([ACGT:]+)/){
		$RT=$1;$RT=~s/://g;
		$R=substr($RT,0,$N);
		$T=substr($RT,$N);
	}
	$a[3]=$R.":".$T;
	## calculate 5p upstream length($T) + 1
	if($a[5] eq "-"){
		##           <=======*TTT
		##  mRNA=============AAAA
		$a[1]=$a[2];
		$a[2]=$a[2]+length($RT)+1;
	}else{
		##    TTT*=====>
		##   AAAAA============
		$a[2]=$a[1];
		$a[1]=$a[1]-length($RT)-1;
	}
	print join("\t",@a[0..5]),"\n";
	
' | bedtools getfasta -fi $2 -bed stdin -s -name  -tab  \
| perl -e 'use strict;
	#CGCCAT:TTTTT::THAP2:1480-1486(-)	gtcaag
	my %res=();
	while(<STDIN>){ chomp; my ($a,$g)=split /\t/,$_;
		my ($rt, $cloc )=split /::/,$a; 
		my ($r,$t)=split/:/,$rt;
		$t=uc $t;
		$g=uc $g;
		if($cloc=~/(\w+):(\d+)-(\d+)\(([+-])\)/){
			my ($chr,$start,$end,$strand)= ($1,$2,$3,$4);
			my $gT=0; if($g=~/(T+)$/){ $gT = length($1);}
			my $i=0; for(;$i <= length($rt) && $i <= length($g);$i++){
				last if( substr($rt,-$i-1,1) ne substr($g,-$i-1,1));
			}
			my $flag=0;
			if( $i > length($t)){
				$flag |= 0x2;
			}
			if( $gT > length($t)){
				$flag |= 0x1;
			}
			if($strand eq "+"){ $start=$end; $strand="-";
			}else{ $start--; $strand="+"; }
			print join("\t",($chr,$start,$start+1,$r.":".$t."::".$g,$flag,$strand)),"\n";
		}
	}
' 
}

3pread.filter__test(){
echo ">chr1
CCCCCCCCCC
CCCCCCTTTT
GGGGGGGGGG
AAAAGGGGGG
ACGTACGTAC" > tmp.fa
echo \
"@HD	VN:1.0	SO:unsorted
@SQ	SN:chr1	LN:16852
@PG	ID:hisat2	PN:hisat2	VN:2.1.0	CL:"/Users/oannes/git/APAchi/bin/Darwin.x86_64/hisat2-align-s --wrapper basic-0 -x THAP2_hg19 -f -U THAP2_read.fa"
r1:CC:TT	0	chr1	19	255	10M	=	37	39	AAAAAAAAAA	*
r2:CC:TT	0	chr1	20	255	10M	*	0	0	AAAAAAAAAA	*
r3:CC:TTT	0	chr1	21	255	10M	*	0	0	AAAAAAAAAA	*	NM:i:1
r4:CC:TT	16	chr1	21	255	10M	=	37	39	AAAAAAAAAA	*
r5:CC:TT	16	chr1	22	255	10M	*	0	0	AAAAAAAAAA	*
r6	16	chr1	23	255	10M	*	0	0	AAAAAAAAAA	*	NM:i:1" \
| samtools view -b - | bedtools bamtobed -bed12 | 3pread.filter -n=1 - tmp.fa
rm tmp.*
}
