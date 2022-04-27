include ../Makefile.defs Makefile.defs

WHEREABOUTS_IMAGE=ghcr.io/k8snetworkplumbingwg/whereabouts:latest-amd64
IMAGE_NAMES := spiderpool-agent spiderpool-controller

.PHONY: kind-init
kind-init: check-tools
	$(QUIET)echo "Install kind cluster..."
	$(QUIET)kube_proxy_mode=$(E2E_KUBE_PROXY_MODE) ip_family=$(E2E_IP_FAMILY) singe_node=$(E2E_SINGE_NODE) kind_image_tag=$(E2E_KIND_IMAGE_TAG) disable_default_cni=$(E2E_DISABLE_DEFAULT_CNI) p2ctl -t $(ROOT_DIR)/test/yamls/kind-config.tmpl > $(ROOT_DIR)/test/yamls/kind-config.yaml
	$(QUIET)cat $(ROOT_DIR)/test/yamls/kind-config.yaml
	kind create cluster --config $(ROOT_DIR)/test/yamls/kind-config.yaml --name $(E2E_CLUSTER_NAME)
	kubectl apply -f $(ROOT_DIR)/test/yamls/cni-install.yaml

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
	$(QUIET)bash scripts/install-macvlan.sh $(E2E_CLUSTER_NAME)
	@kubectl get nodes > /dev/null 2>&1 || echo "failed to setup cluster"


#============ kind-e2e ====================
.PHONY: install-kind
install-kind: check-tools kind-init

.PHONY: kind-clean
kind-clean:
	@echo "Cleanup kind-config.yaml/kind cluster"
	rm -f yamls/kind-config.yaml
	rm -f yamls/10-macvlan.conflist
	kind delete cluster --name $(E2E_CLUSTER_NAME)

.PHONY: check-tools
check-tools:
	$(QUEIT) bash scripts/check-tools.sh

#============ e2e ====================
.PHONY: e2e-test
e2e-test:
	$(QUIET)echo "Run E2E"
	$(QUIET) $(ROOT_DIR)/tools/scripts/ginkgo.sh e2e/*

