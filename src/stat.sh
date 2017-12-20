
stat.lineartrend(){
usage="
$FUNCNAME <input>
	<input.txt> : id positions ctr_counts trt_counts
	 positions,ctr_counts,trt_counts := comman separated integers 
"
if [ $# -lt 1 ];then echo "$usage"; return; fi
local tmpd=`util.mktempd`
echo '
con = file("stdin","r");
line = readLines(con, n=1);
while(length(line) > 0){
        tmp=strsplit(line,"\t")[[1]];
        id=tmp[1];
        x=as.integer(strsplit(tmp[2],",")[[1]]);
        y=as.integer(strsplit(tmp[3],",")[[1]]);
        z=as.integer(strsplit(tmp[4],",")[[1]]);
        xx=unlist(apply(cbind(x,y,z),1,function(d){
                c(rep(d[1],d[2]),rep(d[1],d[3]));
        }))
        yy=unlist(apply(cbind(x,y,z),1,function(d){
                c(rep(1,d[2]),rep(2,d[3]));
        }))
	r=NA;p=NA;
	if(length(x) > 1 && sum(y*z == 0) > 1){
		r=cor.test(xx,yy)$estimate;
		s=r*r*(length(xx)-1);
		p=1-pchisq(s,1);
	}
	cat("OUT",line,r,p,sep="\t",fill=T);
        line=readLines(con,n=1);
}
close(con);
' > $tmpd/cmd
cat $1 | R --no-save -f $tmpd/cmd | grep "OUT" | cut -f 2-
rm -r $tmpd
}
stat.lineartrend__test(){
echo	"id1	1,2,3	10,20,30	300,200,100
id3	1	1	1
id2	1,2,3	10,20,30	0,0,0" \
| stat.lineartrend -
}
