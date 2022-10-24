#!/bin/sh

set -o errexit -o nounset -o xtrace

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)
PROJECT_ROOT_PATH=$( cd ${CURRENT_DIR_PATH}/../.. && pwd )

# up a cluster with kind
create_cluster() {

  # Default Log level for all components in test clusters
  KIND_CLUSTER_LOG_LEVEL=${KIND_CLUSTER_LOG_LEVEL:-4}


  # create the config file
  cat <<EOF > ".tmp/kind-config.yaml"
# config for 1 control plane node and 2 workers (necessary for conformance)
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ${IP_FAMILY:-dual}
networking:
  ipFamily: ${IP_FAMILY:-dual}
  kubeProxyMode: ${KUBE_PROXY_MODE:-iptables}
nodes:
- role: control-plane
- role: worker
kubeadmConfigPatches:
- |
  kind: ClusterConfiguration
  metadata:
    name: config
  apiServer:
    extraArgs:
  controllerManager:
    extraArgs:
  scheduler:
    extraArgs:
  ---
  kind: InitConfiguration
  nodeRegistration:
    kubeletExtraArgs:
  ---
  kind: JoinConfiguration
  nodeRegistration:
    kubeletExtraArgs:
EOF

  kind create cluster \
    --image=kindest/node:${KIND_NODE_TAG:-v1.25.1} \
    --retain \
    --wait=1m \
    -v=3 \
    "--config=.tmp/kind-config.yaml"
}

main() {
  # ensure artifacts (results) directory exists when not in CI
  export ARTIFACTS="${PROJECT_ROOT_PATH}/.tmp"
  mkdir -p "${ARTIFACTS}"

  # export the KUBECONFIG to a unique path for testing
  KUBECONFIG="${ARTIFACTS}/.kube/kind-test-config"
  export KUBECONFIG
  echo "exported KUBECONFIG=${KUBECONFIG}"


  # create the cluster and run tests
  res=0
  create_cluster || res=$?
  exit $res
}

main