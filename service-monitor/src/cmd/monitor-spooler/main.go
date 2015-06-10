// +build windows
// compile= GOOS=windows GOARCH=amd64 go build

package main

import (
	"fmt"
	"io"
	"net/http"
)

func health(w http.ResponseWriter, r *http.Request) {
	s, _ := stateService("spooler")
	if s == 4 {
		// 200: OK
		io.WriteString(w, "OK")
	} else {
		// 503: Service unavailable
		e := fmt.Sprintf("ERROR, windows service 'spooler' is not running, state=%v", s)
		http.Error(w, e, 503)
	}
}

func main() {
	http.HandleFunc("/health", health)
	http.ListenAndServe(":8000", nil)
}
