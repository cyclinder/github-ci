package main

import (
	"fmt"
	"testing"
)

func Test_parseConfig(t *testing.T) {
	tests := []struct {
		name  string
		stdin []byte
		err   error
	}{
		{
			name: "migrate_route no define, but we give it default value",
			err:  nil,
			stdin: []byte(`{
				"cniVersion": "0.3.1",
				"name": "veth",
				"type": "veth",
				"service_hijack_subnet": ["10.244.64.0/18"],
				"overlay_hijack_subnet": ["10.244.0.0/18"],
				"rp_filter": {
					"enable": true,
					"value": 0
				},
				"prevResult": {
					"interfaces": [
						{"name": "host"},
						{"name": "container", "sandbox":"netns"}
					],
					"ips": [
						{
							"version": "4",
							"address": "10.0.0.1/24",
							"gateway": "10.0.0.1",
							"interface": 0
						},
						{
							"version": "6",
							"address": "2001:db8:1::2/64",
							"gateway": "2001:db8:1::1",
							"interface": 0
						}
					]
				}
			}`),
		}, {
			name:  "err rp_filter value(3)",
			stdin: []byte("\t\"cniVersion\": \"0.3.1\",\n\t\"name\": \"veth\",\n\t\"type\": \"veth\",\n\t\"routes\": [\n\t\t{\"dst\": \"10.244.0.0/16\"},\n    \t{\"dst\": \"172.16.0.0/24\"}\n\t],\n\t\"rp_filter\": {\n\t\t\"set_host\": true,\n\t\t\"value\": 3\n\t},\n\t\"prevResult\": {\n\t\t\"interfaces\": [\n\t\t\t{\"name\": \"host\"},\n\t\t\t{\"name\": \"container\", \"sandbox\":\"netns\"}\n\t\t],\n\t\t\"ips\": [\n\t\t\t{\n\t\t\t\t\"version\": \"4\",\n\t\t\t\t\"address\": \"10.0.0.1/24\",\n\t\t\t\t\"gateway\": \"10.0.0.1\",\n\t\t\t\t\"interface\": 0\n\t\t\t},\n\t\t\t{\n\t\t\t\t\"version\": \"6\",\n\t\t\t\t\"address\": \"2001:db8:1::2/64\",\n\t\t\t\t\"gateway\": \"2001:db8:1::1\",\n\t\t\t\t\"interface\": 0\n\t\t\t}\n\t\t]\n\t}"),
			err:   nil,
		}, {
			name: "logOption not define,but we give it default value",
			err:  nil,
			stdin: []byte(`{
				"cniVersion": "0.3.1",
				"name": "veth",
				"type": "veth",
				"service_hijack_subnet": ["10.244.64.0/18"],
				"overlay_hijack_subnet": ["10.244.0.0/18"],
				"rp_filter": {
					"enable": true,
					"value": 0
				},
				"prevResult": {
					"interfaces": [
						{"name": "host"},
						{"name": "container", "sandbox":"netns"}
					],
					"ips": [
						{
							"version": "4",
							"address": "10.0.0.1/24",
							"gateway": "10.0.0.1",
							"interface": 0
						},
						{
							"version": "6",
							"address": "2001:db8:1::2/64",
							"gateway": "2001:db8:1::1",
							"interface": 0
						}
					]
				}
			}`),
		}, {
			name: "service or pod cidr must be define",
			err:  fmt.Errorf("the subnet of overlay cni(such as calico or cilium) must be given"),
			stdin: []byte(`{
				"cniVersion": "0.3.1",
				"name": "veth",
				"type": "veth",
				"service_hijack_subnet": ["10.244.64.0/18"],
				"overlay_hijack_subnet": [],
				"rp_filter": {
					"enable": true,
					"value": 0
				},
				"prevResult": {
					"interfaces": [
						{"name": "host"},
						{"name": "container", "sandbox":"netns"}
					],
					"ips": [
						{
							"version": "4",
							"address": "10.0.0.1/24",
							"gateway": "10.0.0.1",
							"interface": 0
						},
						{
							"version": "6",
							"address": "2001:db8:1::2/64",
							"gateway": "2001:db8:1::1",
							"interface": 0
						}
					]
				}
			}`),
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := parseConfig(tt.stdin)
			if err != nil && err != tt.err {
				t.Errorf("parseConfig() error = %v, wantErr %v", err, tt.err)
				return
			}
		})
	}
}
