#！/bin/bash
## SPDX-License-Identifier: Apache-2.0
## Copyright Authors of Spider


export PATH=$PATH:$(go env GOPATH)/bin
OS=$(uname | tr 'A-Z' 'a-z')

# kubectl
kubectl help > /dev/null 2>&1
if [ $? -eq 127 ] ; then
  echo "kubectl not found, Install..."
  curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/$OS/amd64/kubectl
  chmod +x /usr/local/bin/kubectl
fi

# Install Kind Bin
if ! kind > /dev/null 2>&1 ; then
  echo "kind not found, Install..."
  curl -Lo /usr/local/bin/kind https://github.com/kubernetes-sigs/kind/releases/download/v0.12.0/kind-$OS-amd64
  chmod +x /usr/local/bin/kind
fi
echo "kind version: $(kind version)"

# Install Helm
if ! helm > /dev/null 2>&1 ; then
  echo "helm not found, Install..."
  curl -Lo /tmp/helm.tar.gz "https://get.helm.sh/helm-v3.8.1-$OS-amd64.tar.gz"
  tar -xzvf /tmp/helm.tar.gz && mv $OS-amd64/helm  /usr/local/bin
  chmod +x /usr/local/bin/helm
  rm /tmp/helm.tar.gz
  rm $OS-amd64/LICENSE
  rm $OS-amd64/README.md
fi
echo "helm version: $(helm version)"

# Install p2ctl
p2ctl --version &> /dev/null
if [ $? -eq 127 ]; then
  echo "Install p2ctl..."
  curl -Lo /usr/local/bin/p2ctl https://github.com/wrouesnel/p2cli/releases/download/r13/p2-$OS-x86_64
  chmod +x /usr/local/bin/p2ctl
fi
