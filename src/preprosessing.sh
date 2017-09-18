
fastq.trim(){
usage="
$FUNCNAME [options] <fastq> 
 [options]:
	-5 <str>: trim 5' adaptor 
	-3 <str>: trim 3' adaptor
	-m <int>: minimum length after trimming (default 1)
	-t : remove untrimmed 
"
local OPTARG; local OPTIND;
local FPRIME=1; local TONLY=0;
local BARCODE=""; local MINLEN=1;
while getopts ":5:3:m:t" opt; do
	case $opt in 
		5) FPRIME=1;BARCODE=$OPTARG;;
		3) FPRIME=0;BARCODE=$OPTARG;;
		t) TONLY=1;;
		m) MINLEN=$OPTARG;;
		?) echo "$usage";return;;
	esac
done
shift $((OPTIND-1))
if [ $# -lt 1 ];then echo "$usage"; return; fi
        cat $1 | perl -e 'use strict; 
	my $FIVE_PRIME='$FPRIME';
	my $TRIMMED_ONLY='$TONLY';
	my $MIN_LEN='$MINLEN';
	my $BARCODE=qw/'$BARCODE'/;

        my @buf=();
        my $n_tot=0; my $n_hit=0;
	#print $BARCODE," ",$MIN_LEN,"\n";

        while(<STDIN>){ chomp; push @buf,$_;
                if(scalar @buf == 4){
                        $n_tot ++;
                        if($buf[1] =~ /($BARCODE)/g || $TRIMMED_ONLY != 1){
				$buf[0]=~tr/ /_/;
				if($FIVE_PRIME){
					my $off=$+[0];
					if(length($buf[1]) - $off >= $MIN_LEN){
						$n_hit ++;
						print $buf[0],":",$1,"\n";
						print substr($buf[1],$off),"\n";
						print $buf[2],"\n";
						print substr($buf[3],$off),"\n";
					}
				}else{
					my $off=$+[0]-1;
					if( $off >= $MIN_LEN){
						$n_hit ++;
						print $buf[0],":",$1,"\n";
						print substr($buf[1],0,$off),"\n";
						print $buf[2],"\n";
						print substr($buf[3],0,$off),"\n";
					}
				}
			}
                        @buf=();
                }
        }
        print {*STDERR} "#total=$n_tot\n";
        print {*STDERR} "#passed=$n_hit\n";
        '
}

fastq.trim__test(){
echo \
"@a
TTTTAAGTTTTTTAAAAA
+
IIIIIIIIIIIIIIIIII
@b
AAGTTTTTTAAAAA
+
IIIIIIIIIIIIII" > tmp.a
cat tmp.a;
echo " trim AA at 5'"
trim -5 AA tmp.a AA 
echo " trim AAA at 3'"
trim -3 AAA tmp.a AAA 
}
