package main
import(
	"io"
	"net/http"
	//"syscall"
	//"os"
	"os/exec"
	"log"
	"fmt"
)

func get_bam(url string, region string) []byte {
	//url := string("http://tanlab.ucdenver.edu/hmKim/Panc/Panc-1.bam");
	//region := string("chr2:10000-200000");
	out, err := exec.Command("samtools","view",url,region).Output();
	if err != nil{ log.Fatal(err);}
	return( out );
}

func hello(w http.ResponseWriter, r *http.Request){
	io.WriteString(w,"hello!");
	//err := exec.LookPath("samtools");
	//if err != nil { panic(err); }
} 


func main(){
	mux := http.NewServeMux();
	mux.HandleFunc("/",hello);
	url := string("http://tanlab.ucdenver.edu/hmKim/Panc/Panc-1.bam");
	region := string("chr2:10000-200000");
	res :=get_bam(url,region);
	fmt.Printf("%s\n",res);	
	http.ListenAndServe(":8000",mux);
}
