package main

import(
"os"
"fmt"
)

func main(){
	cmd := os.Args[1]
	fmt.Printf("I run %s \n",cmd)
}
