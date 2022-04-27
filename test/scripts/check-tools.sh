#！/bin/bash
## SPDX-License-Identifier: Apache-2.0
## Copyright Authors of Spider

set -e

OS=$(uname | tr 'A-Z' 'a-z')
READY=true

echo "Check kubectl/docker/helm/kind/p2ctl is ready:"

# check docker kind helm p2ctl is exist:
if ! command -v docker > /dev/null 2>&1 ; then
  echo "docker no ready, Please install it manually"
  READY=false
else
  echo "docker ready"
fi

if ! command -v kubectl > /dev/null 2>&1 ; then
  echo "kubectl no ready, Please visit "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/$OS/amd64/kubectl" install it or use ./test/install-tools.sh"
  READY=false
else
  echo "kubectl ready!"
fi
if ! command -v kind > /dev/null 2>&1 ; then
  echo "kind no ready, Please visit "https://github.com/kubernetes-sigs/kind/releases" install it or use ./test/install-tools.sh"
  READY=false
else
  echo "kind ready!"
fi

if ! command -v helm > /dev/null 2>&1 ; then
  echo "helm no ready, Please visit "https://github.com/helm/helm/releases" install it or use ./test/install-tools.sh"
  READY=false
else
  echo "helm ready!"
fi

if ! command -v p2ctl > /dev/null 2>&1 ; then
  echo "p2ctl no ready, Please visit "https://github.com/wrouesnel/p2cli/releases" install it or use ./test/install-tools.sh"
  READY=false
else
  echo "p2ctl is ready!"
fi

if [ "$READY" = "false" ]; then
  echo "Some tools no ready, failed to setup kind cluster"
  exit 1
fi