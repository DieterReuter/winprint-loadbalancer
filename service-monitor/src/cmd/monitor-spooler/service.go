package main

import (
	"fmt"

	"golang.org/x/sys/windows/svc/mgr"
)

func stateService(name string) (int, error) {
	m, err := mgr.Connect()
	if err != nil {
		return 0, err
	}
	defer m.Disconnect()
	s, err := m.OpenService(name)
	if err != nil {
		return 0, fmt.Errorf("could not access service: %v", err)
	}
	defer s.Close()
	q, err := s.Query()
	if err != nil {
		return 0, fmt.Errorf("could not query service: %v", err)
	}
	return int(q.State), nil
}
