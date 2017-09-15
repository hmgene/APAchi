

## data obtained from  https://raw.githubusercontent.com/Bioconductor-mirror/cleanUpdTSeq/release-3.3/inst/extdata/test.bed
data="chr10:2965327:2965327:6hpas-22249:1:-   TCTTCATCATGGTCATCTCGCACCAGAGAGTGTGCCAGGG        CAGGAAGTTTTACCTGTCTGTCATTATCGT
chr10:2966558:2966558:6hpas-22250:1:-   ACCCTGGTGAGGGTATAGAGCTGGTCCAGTGTGCCACGGC        AAAGAGGAAAACAGCATTGTTCCTCCTGGA
chr10:2974251:2974251:6hpas-22251:2:-   TGATTTGTTTGTAACTGATTTTATCTTTTAATAAAAAAGA        AAAAAGAAAGTCAAGCCAAGAGGCAAATAC
chr10:2978441:2978441:6hpas-22252:1:-   GGAGCGCGACCGCATCAACAAAATCTTGCAGGATTATCAG        AAGAAAAAGATGGTGAGTTATTATCATTCA
chr11:16772291:16772291:6hpas-33204:1:- AGGGAAATAAATACAAAAGAATAAAAATATGATTCATTGT        AAGAAAAACACTTTAGCTACAAAAGTCCTT
chr11:16777848:16777848:6hpas-33205:1:- ATTTAGTTGGGTATTATTTCAAATAAAGAGAGAGAGAGAC        ACAAAAACTACATCAAATTTGAGGACAAAA
chr11:17122845:17122845:6hpas-33209:1:- TCAAAGTTAATGTACATTAAAAATGAGTCAAAATGTTTAG        AATAAAAGAAGATTTGAATGATATATTCTT
chr11:17122856:17122856:6hpas-33210:2:- TGAATGTATTTTCAAAGTTAATGTACATTAAAAATGAGTC        AAAATGTTTAGAATAAAAGAAGATTTGAAT
chr11:17123062:17123062:6hpas-33211:1:- TTGGATAGTAAATTAATTATTTATAAAGTTTCTAGATTAC        ATAAAGAAAATAAATCTGTTATATCTGTAT
chr11:17123194:17123194:6hpas-33212:1:- TGATCTCCATATGATATCACCGTCCCTATTTAACTTAAAG        GTTTATCTTGTTTATAAGGGTGTGATAGAA
chr11:17123754:17123754:6hpas-33213:3:- CCTCGATGATGCCGCCCGCAAAGCTGTCGCCGCCATTGCC        AAGAAATAAATGCAAATATTCATAATGCAC
chr11:17204740:17204740:6hpas-33214:1:- ATCGCCATTTTGCCCGTTCGTCATCGCATAAACCTGAGAC        AACCAAAAAAGGGCAAAGAGGCGGAGCTAC
chr12:25855374:25855374:6hpas-43855:1:- AAGGCCCAAACAGTAAAAAAAAATAAGACTGCTCTGCTTT        AAAAAAAAAAAAAAAAAAACCTTCAGTGGG
chr12:26155099:26155099:6hpas-43856:2:- AAGGTGTTTACATGTCTGTACTGCACTTCAATAATGTGAC        TAAAATAGGAATGCTCCAAATGGCTTCATT
chr12:26155123:26155123:6hpas-43857:2:- TTACACAACGCTAATGGTTTTATTAAGGTGTTTACATGTC        TGTACTGCACTTCAATAATGTGACTAAAAT
chr12:26170452:26170452:6hpas-43858:1:- TTTATTTTAATAAATAAGCATTTTTAAAAGACTTCATATT        AATCAAACATTGTCTTGTCTATCATTGCCT
chr12:26295950:26295950:6hpas-43859:3:- GAGAAGGAGAATGAGGAGAGTTTGAATCAAAATAATAATT        GAAAATAAAAAAAATAAAAAAAACTGGATG
chr12:26295962:26295962:6hpas-43860:5:- GAGGAGAAGCAAGAGAAGGAGAATGAGGAGAGTTTGAATC        AAAATAATAATTGAAAATAAAAAAAATAAA
chr15:733981:733981:6hpas-71514:10:-    ATCTACAACCCCAAATCAGAAAAAGATTGGCACAGTATGG        AAAACACAAATAAAAAAGAAAGTGATTTAC
chr15:734009:734009:6hpas-71515:2:-     TTTGTTACTTGAGACGCATCAAGATTTTATCTACAACCCC        AAATCAGAAAAAGATTGGCACAGTATGGAA
chr15:735146:735146:6hpas-71516:13:-    ATTTGGTCCGGATCAAGGGTAATAAATGACACATTGTTGC        ATTTTCTGCCGTCTTTGGGTCGTTTTCACA
chr15:735378:735378:6hpas-71517:5:-     GTTTTGAAATTGTGAGTATAAAGTAAATCTTTCAGTCATC        AGTGTTGAGTTTCATATACAGGAATCATGT
chr15:735597:735597:6hpas-71518:2:-     GCTTCACGGTTGCCCTCAGTGTGGGAAGAGCTTCACTTGG        AAAAAAACCCTTATTGAGCATATGAAGGTT
chr16:18304846:18304846:6hpas-78439:10:+        GGTCATTGTCCTGCAAAATGGACTACTTAACCGAACTGGA        GAAGTATAAGAAGTAAGTACATTAAAGCTA
chr16:18312684:18312684:6hpas-78440:1:+ TGGATTTAAATAACAAACAAGTTAAATAAAACGATTTGTA        AAAAAATAAAACAACTGAAGAAGAAAATGA
chr16:18316016:18316016:6hpas-78441:1:+ ATCTGCTTCAAAATGGATGCTCTGTTGAATCCTGAGCTCA        GGTAATCTTTCAAGTGCTGCTATTGAGCCA
chr16:18316389:18316389:6hpas-78442:1:+ AAATGCTTGCACATAATAAATGTAGGCTTAAAAGATTTCA        AAACGTTTGTGAGAGACGGATTTTACTTTG"


polyafilter.updnseq2fea(){
usage="$FUNCNAME <input>
	<input> : tuples of id, upstream sequence, and downstream sequence
	e.g.
	polyA1    ATCTACAACCCCAAATCAGAAAAAGATTGGCACAGTATGG        AAAACACAAATAAAAAAGAAAGTGATTTAC

"; if [ $# -lt 1 ];then echo "$usage"; return; fi

cat $1 | perl -e 'use strict;
	my @res=();
	my @C=(); ## column names

	sub genkmer{
		my ($prefix,$t,$l,$r) = @_;
		if($l<=0){ 
			push @$r,$prefix;
			return;
		}
		foreach my $nu ( "A", "C", "G", "T"){
			$t->{$nu} = undef;
			genkmer($prefix.$nu,$t->{$nu},$l-1,$r);
		}
	}


	my %trie=();
	my @kmers1=();
	my @kmers2=();
	my @kmers6=();
	genkmer("",\%trie,1,\@kmers1);
	genkmer("",\%trie,2,\@kmers2);
	genkmer("",\%trie,6,\@kmers6);
	push @C,"n.dnAdist";
	foreach my $e (@kmers1){ push @C,"n.dn".$e; }
	foreach my $e (@kmers2){ push @C,"n.dn".$e; }
	foreach my $e (@kmers6){ push @C,"b.up".$e; }
	
	
	while(<STDIN>){chomp; $_=~s/\s+/\t/g;
		my ($id,$upseq,$dnseq) = split /\t/,$_;
		$upseq= uc $upseq; $dnseq=uc $dnseq;

		my %D=();

		my %Adist=();
		## feature prefix:  m: multinomial, n:normal, b:binomial
		## handle downstream features
		for(my $i=0; $i<length($dnseq); $i++){
			my $nu=substr($dnseq,$i,1);
			$D{"n.dn".$nu} ++; 
			if($nu eq "A"){
				$Adist{sum} += ($i+1); # 1-base
				$Adist{num} ++;
			}
			if( length($dnseq)-$i > 2){
				my $nu2=substr($dnseq,$i,2);
				$D{"n.dn".$nu2}++;
			}
		}
		if ( defined $Adist{sum} ){
			$D{"n.dnAdist"}=int($Adist{sum}/$Adist{num});
		}else{
			$D{"n.dnAdist"}=length($dnseq);
		}

		## hexamers in the upstream
		my $k=6;
		for(my $i=0; $i<length($upseq) - $k + 1; $i++){
			$D{"b.up".substr($upseq,$i,$k)} = 1;
		}
		#print $_,"\t"; print join("\t",( map{ "$_:$D{$_}"} keys %D)),"\n";
		push @res,[ $id, \%D ];
	}
	print "id\t",join("\t",@C),"\n";
	foreach my $i (@res){
		print $i->[0];
		my $d=$i->[1];
		foreach my $c (@C){
			my $v= defined $d->{$c} ? $d->{$c} : 0;	
			print "\t$v";
		}
		print "\n";
	}
'
}

polyafilter.updnseq2fea.test(){
	echo "$data" | polyafilter.updnseq2fea - 
}

bed.seq(){
usage="$FUNCNAME <genome.fa> <bed>  [options]
 [options] : 
  -s : revCompment for the negative strand 
"
if [ $# -lt 2 ];then echo "$usage"; return; fi
#n1::one:0-3(+)
	bedtools getfasta -fi $1 -bed ${2/-stdin} ${@:3} -name  -tab \
	| perl -ne 'chomp; if( $_=~ /(.+)::(.+)\t([ACGTacgt]+)/){
		print $1,"\t",$3,"\n";
		}
	'

}
bed.seq__test(){
echo \
">one 
ATGCATGCATGCATGCATGCATGCATGCAT 
GCATGCATGCATGCATGCATGCATGCATGC 
ATGCAT 
>two another chromosome 
ATGCATGCATGCAT 
GCATGCATGCATGC" > tmp.fa
samtools faidx tmp.fa
echo \
"one	0	3	n1	0	+
two	0	5	n2	0	-" > tmp.bed
bed.seq tmp.fa tmp.bed -s 
rm tmp.*
}

bed.enc(){
## encode bed6 in the name field 
	cat $1 | awk -v OFS="\t" -v j=${2:-"@"} '{ n=$1;for(i=2;i<= 6;i++){ n=n j $(i);} $4=n; }1' 
}
bed.3p(){
 	awk -v OFS="\t" '{ if($6=="-"){$3=$2+1;} $2=$3-1; print $0; }' $1
}

bed.5p(){
 	awk -v OFS="\t" '{if($6=="-"){$2=$3-1;}$3=$2+1; print $0; }' $1
}

bed.flank(){
usage="
FUNCT : extract flanking regions
USAGE : $FUNCNAME <bed> <left> <right> [<strand_opt>]
	<strand_opt> :  -s: strand specific
" 
if [ $# -lt 3 ];then echo "$usage"; return; fi
	awk -v OFS="\t" -v L=$2 -v R=$3 -v S=$4 '{ 
		if(S == "-s"  && $6 == "-"){
			$2=$2-R; $3=$3+L;
		}else{ $2=$2-L; $3=$3+R; } 
		if( $2 > 0  && $3 > $2){
			print $0;
		}
	}' $1;
}

polyafilter.bed2updnseq(){
usage="$FUNCNAME <bed> <fasta> [<upstream> <downstream>]"
if [ $# -lt 2 ];then echo "$usage"; return; fi
	local UP=${3:-40};	
	local DN=${4:-30};	
	bed.enc $1 ":" | bed.flank - $(( $UP - 1 )) $DN -s \
	| bed.seq $2 - -s \
	| perl -ne 'chomp; my ($id,$seq)=split/\t/,$_;
		print $id,"\t",substr($seq,0,'$UP'),"\t",substr($seq,'$UP','$DN'),"\n";
	' 
}
polya.filter(){ 
usage="
FUNCT: Filter inter-priming artefacts 
USAGE: $FUNCNAME <bed> <fasta> [<model.rda>]
REFER: heppard, S., Lawson, N.D. & Zhu, L.J., 2013.Bioinformatics (Oxford, England), 29(20), pp.2564–2571.
"
if [ $# -lt 2 ];then echo "$usage"; return; fi
	local MODEL=${3:-$APACHI_HOME/data/cleanUpdTSeq/cleanUpdTSeq.model.rda};
	polyafilter.bed2updnseq $1 $2 \
	| polyafilter.updnseq2fea -  \
	| naivebayes.e1071_predict - $MODEL \
	| cut -f1,2 | tr ":" "\t"
}

polya.filter.test(){
echo "todo: ";
}
