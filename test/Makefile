include ../Makefile.defs Makefile.defs

WHEREABOUTS_IMAGE=ghcr.io/k8snetworkplumbingwg/whereabouts:latest-amd64
IMAGE_NAMES := spiderpool-agent spiderpool-controller

.PHONY: all
all: usage

#============ kind-e2e ====================
.PHONY: e2e
e2e:  kind-init e2e-test

.PHONY: kind-init
kind-init: prepare
	$(QUIET)echo "Install kind cluster..."
	$(QUIET)kube_proxy_mode=$(E2E_KUBE_PROXY_MODE) ip_family=$(E2E_IP_FAMILY) singe_node=$(E2E_SINGE_NODE) kind_image_tag=$(E2E_KIND_IMAGE_TAG) disable_default_cni=$(E2E_DISABLE_DEFAULT_CNI) p2ctl -t $(ROOT_DIR)/test/yamls/kind-config.tmpl > $(ROOT_DIR)/test/yamls/kind-config.yaml
	$(QUIET)@cat $(ROOT_DIR)/test/yamls/kind-config.yaml
	kind create cluster --config $(ROOT_DIR)/test/yamls/kind-config.yaml --name $(E2E_CLUSTER_NAME) --kubeconfig $(HOME)/kind/$(E2E_CLUSTER_NAME)/.kube/config

ifeq ($(INSTALL_MACVLAN)_$(INSTALL_WHEREABOUTS),true_true)
	$(QUIET)echo "Install macvlan + whereabouts"
	$(QUIET)bash scripts/install-whereabouts.sh $(E2E_CLUSTER_NAME)
	type=whereabouts p2ctl -t yamls/10-macvlan.tmpl > yamls/10-macvlan.conflist
endif
ifeq ($(INSTALL_MACVLAN)_$(INSTALL_SPIDER),true_true)
	$(QUIET) echo "Install macvlan + spiderpool"
	type=spiderpool p2ctl -t yamls/10-macvlan.tmpl > yamls/10-macvlan.conflist
	$(MAKE) -C $(ROOT_DIR) install
endif
	$(QUIET)@bash scripts/cni-install.sh $(E2E_CLUSTER_NAME)
	$(QUIET)@bash scripts/install-macvlan.sh $(E2E_CLUSTER_NAME)
	@kubectl get nodes --kubeconfig $(HOME)/kind/$(E2E_CLUSTER_NAME)/.kube/config > /dev/null 2>&1 || echo "failed to setup cluster"

.PHONY: kind-clean
kind-clean:
	@echo "Cleanup kind-config.yaml/kind cluster"
	rm -f yamls/kind-config.yaml
	rm -f yamls/10-macvlan.conflist
	rm -f $(HOME)/kind/$(E2E_CLUSTER_NAME)/.kube/config
	kind delete cluster --name $(E2E_CLUSTER_NAME)

.PHONY: prepare
prepare:
	$(QUEIT) @bash scripts/prepare.sh

#============ e2e ====================
.PHONY: e2e-test
e2e-test:
	$(QUIET)echo "Run E2E"
	$(QUIET) $(ROOT_DIR)/tools/scripts/ginkgo.sh -v --label-filter="$(E2E_GINKGO_LABELS)"  ipFamily=$(E2E_IP_FAMILY) clusterName=$(E2E_CLUSTER_NAME) e2e/*

usage:
	@echo "usage:"
	@echo -e "\033[35m make prepare \033[0m : Check some required tools is exist like docker/helm.etc and download cni-plugins"
	@echo -e "\033[35m make init \033[0m    : Setup a kind cluster, Such as: kind-init INSTALL_MACVLAN=true INSTALL_WHEREABOUTS=true E2E_CLUSTER_NAME=spider,More config refer to Makefile.defs(e2e-kind-config)"
	@echo -e "\033[35m make e2e-test \033[0m: Ginkgo test,Such as: make e2e-test, More config refer to Makefile.defs(e2e-kind-config)"
	@echo -e "\033[35m make kind-clean \033[0m: Clean kind cluster and some config file, Such as: make kind-clean E2E_CLUSTER_NAME=spider"
	@echo -e "\033[35m make e2e \033[0m: prepare -> kind-init -> e2e-test "
