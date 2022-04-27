#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Copyright Authors of Spider-net

# Copy 10-macvlan.tmpl to kind-node
NODES=($(docker ps | grep $1 | awk '{print $1}'))
for node in ${NODES[@]}
do
  echo "docker cp yamls/10-macvlan.conflist $node:/etc/cni/net.d"
  docker cp yamls/10-macvlan.conflist $node:/etc/cni/net.d
done
