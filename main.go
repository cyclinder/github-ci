package main

import "fmt"

func main() {
	conf := `{
	"name": "node-cni-network",
	"type": "multus",
	"logLevel": "debug",
	"logFile": "/var/log/multus.log",
	"logOptions": {
		"maxAge": 5,
		"maxSize": 100,
		"maxBackups": 5,
		"compress": true
	}
	"kubeconfig": "/etc/kubernetes/node-kubeconfig.yaml",
	"delegates": [{
		"type": "weave-net"
	}],
	"runtimeConfig": {
		"portMappings": [
			{"hostPort": 8080, "containerPort": 80, "protocol": "tcp"}
		]
	}
}`
	fmt.Println(conf)
}
