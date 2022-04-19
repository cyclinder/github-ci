#！/bin/bash

# Install Kind Bin
curl -Lo /usr/local/bin/kind https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-$(uname)-amd64
chmod +x /usr/local/bin/kind

# Install Helm
curl -Lo helm.tar.gz "https://get.helm.sh/helm-v3.8.1-linux-amd64.tar.gz"
tar -xzvf helm.tar.gz && mv linux-amd64/helm /usr/local/bin
chmod +x /usr/local/bin/helm
rm -f helm.tar.gz

# Install p2ctl
curl -Lo /usr/local/bin/p2ctl https://github.com/wrouesnel/p2cli/releases/download/r12/p2-linux-$(uname -i)
chmod +x /usr/local/bin/p2ctl

# Install ginkgo
go install github.com/onsi/ginkgo/ginkgo@latest

