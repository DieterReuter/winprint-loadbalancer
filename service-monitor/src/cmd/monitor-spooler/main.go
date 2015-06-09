package main

// compile= GOOS=windows GOARCH=amd64 go build

import (
	"io"
	"net/http"
	"os/exec"
)

func health(w http.ResponseWriter, r *http.Request) {
	cmd := exec.Command("cmd.exe", "/c", "sc query spooler | findstr RUNNING")
	err := cmd.Run()
	if err == nil {
		// 200: OK
		io.WriteString(w, "OK")
	} else {
		// 503: Service unavailable
		http.Error(w, "ERROR, windows service 'spooler' is not running", 503)
	}
}

func main() {
	http.HandleFunc("/health", health)
	http.ListenAndServe(":8000", nil)
}
