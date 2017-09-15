

sim.3readp(){
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




