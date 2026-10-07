// hello.go: a friendly greeting from tico.

package main

import (
	"fmt"
	"os"
)

func main() {
	names := os.Args[1:]
	if len(names) == 0 {
		names = []string{"world"}
	}

	for _, name := range names {
		fmt.Printf("Hello, %s!\n", name)
	}
}
