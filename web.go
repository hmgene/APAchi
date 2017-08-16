package main
import(
	"io"
	"net/http"
	"syscall"
	"os"
	"os/exec"
)

func hello(w http.ResponseWriter, r *http.Request){
	io.WriteString(w,"hello!");
	cmd, err0 := exec.LookPath("samtools");
	if err0 != nil {
		panic(err0);
	}
	err := syscall.Exec(cmd,[]string{"samtools","view","http://tanlab.ucdenver.edu/hmKim/Panc/Panc-1.bam","chr22:10000-200000"},os.Environ());
	if err != nil {
	}
} 


func main(){
	mux := http.NewServeMux();
	mux.HandleFunc("/",hello);
	http.ListenAndServe(":8000",mux);
}
