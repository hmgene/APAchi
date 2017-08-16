package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"github.com/biogo/hts/bam"
	"github.com/biogo/hts/bgzf"
	"github.com/biogo/hts/sam"
)

var (
	require = flag.Int("f", 0, "required flags")
	exclude = flag.Int("F", 0, "excluded flags")
	file    = flag.String("file", "", "input file (empty for stdin)")
	conc    = flag.Int("threads", 0, "number of threads to use (0 = auto)")
	help    = flag.Bool("help", false, "display help")
)

const maxFlag = int(^sam.Flags(0))

func main() {
	flag.Parse()
	if *help {
		flag.Usage()
		os.Exit(0)
	}

	if *require > maxFlag {
		flag.Usage()
		log.Fatal("required flags (f) out of range")
	}
	reqFlag := sam.Flags(*require)

	if *exclude > maxFlag {
		flag.Usage()
		log.Fatal("excluded flags (F) out of range")
	}
	excFlag := sam.Flags(*exclude)

	var r io.Reader
	//file := []byte("http://tanlab.ucdenver.edu/hmKim/Panc/Panc-1.bam")
	

	if *file == "" {
		r = os.Stdin
	} else {
		f, err := os.Open(*file)
		if err != nil {
			log.Fatalf("could not open file %q:", err)
		}
		defer f.Close()
		ok, err := bgzf.HasEOF(f)
		if err != nil {
			log.Fatalf("could not open file %q:", err)
		}
		if !ok {
			log.Printf("file %q has no bgzf magic block: may be truncated", *file)
		}
		r = f
	}

	b, err := bam.NewReader(r, *conc)
	if err != nil {
		log.Fatalf("could not read bam:", err)
	}
	defer b.Close()

	// We only need flags, so skip variable length data.
	b.Omit(bam.AllVariableLengthData)

	var n int
	for {
		rec, err := b.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatalf("error reading bam: %v", err)
		}
		if rec.Flags&reqFlag == reqFlag && rec.Flags&excFlag == 0 {
			n++
		}
	}

	fmt.Println(n)
}
