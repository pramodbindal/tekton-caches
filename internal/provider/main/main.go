package main

import (
	"fmt"
	"github.com/openshift-pipelines/tekton-caches/internal/tar"
)

func main() {
	err := tar.Tarit("/tmp/1714", "/tmp/cache.tar.gz")
	if err != nil {
		println(err.Error())
		panic(err)
	}
	fmt.Printf("Done")
}
