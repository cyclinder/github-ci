kube-proxy_mode ?= iptables # iptables or ipvs, default iptables
ip_family ?= ipv4 # ipv4 or ipv6 or dual, default ipv4
multi_node ?= true # true is three node cluster, false is one master cluster, default true
kind_image_tag ?= v1.22.1 # kubernetes version, default v1.22.1




include ./Makefile.defs

all: build-bin install-bin

.PHONY: all build install

SUBDIRS := cmd/spiderpool-agent cmd/spiderpool-controller cmd/spiderpoolctl cmd/spiderpool


build-bin:
	for i in $(SUBDIRS); do $(MAKE) $(SUBMAKEOPTS) -C $$i all; done

install-bin:
	$(QUIET)$(INSTALL) -m 0755 -d $(DESTDIR_BIN)
	for i in $(SUBDIRS); do $(MAKE) $(SUBMAKEOPTS) -C $$i install; done

install-bash-completion:
	$(QUIET)$(INSTALL) -m 0755 -d $(DESTDIR_BIN)
	for i in $(SUBDIRS); do $(MAKE) $(SUBMAKEOPTS) -C $$i install-bash-completion; done

clean:
	-$(QUIET) for i in $(SUBDIRS); do $(MAKE) $(SUBMAKEOPTS) -C $$i clean; done
	-$(QUIET) rm -rf $(DESTDIR_BIN)
	-$(QUIET) rm -rf $(DESTDIR_BASH_COMPLETION)




# ========kind========= #
.PHONY: install-tools
install-tools:
	@echo "Run install-tools"
	bash scripts/install-tools.sh

.PHONY: kind-init
kind-init:
	@echo "kind-init"
	KUBE_PROXY_MODE=$(kube-proxy_mode) IP_FAMILY=$(ip_family) MULTI_NODE=$(multi_node) KIND_IMAGE_TAG=$(kind_image_tag) \
    p2ctl -t images/kind-config.tmpl > images/kind-config.yaml
	kind create cluster --config images/kind-config.yaml --name spider-kind
	kubectl get nodes

.PHONY: kind-init-vlan
kind-init-vlan:
	@echo "kind-init-vlan"

.PHONY: kind-init-ipv6
kind-init-ipv6:
	@echo "kind-init-ipv6"
	KUBE_PROXY_MODE=iptables IP_FAMILY=ipv6 MULTI_NODE=true KIND_IMAGE_TAG=1.22.1 p2ctl -t images/kind-config.tmpl > images/kind-config.yaml

.PHONY: kind-init-dual
kind-init-dual:
	@echo "kind-init-dual"
	KUBE_PROXY_MODE=iptables IP_FAMILY=dual MULTI_NODE=true KIND_IMAGE_TAG=1.22.1 p2ctl -t images/kind-config.tmpl > images/kind-config.yaml

