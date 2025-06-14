#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

DEFAULT_INTERFACE=eth0
VLANID1=100
VLANID2=200
VLANID1_IP=172.100.0.100/16
VLANID2_IP=172.200.0.100/16
VLANID1_IP6=fd00:172:100::100/64
VLANID2_IP6=fd00:172:200::100/64

res=0
kind_nodes=$(docker ps  | egrep "kindest/node.* ${IP_FAMILY}-(control-plane|worker)"  | awk '{print $1}')
for node in ${kind_nodes}; do
  docker exec ${node} ip link add link ${DEFAULT_INTERFACE} name ${DEFAULT_INTERFACE}.${VLANID1} type vlan id ${VLANID1}  || res=$?
  docker exec ${node} ip link add link ${DEFAULT_INTERFACE} name ${DEFAULT_INTERFACE}.${VLANID2} type vlan id ${VLANID2}  || res=$?
  if [[ ${res} -ne "0" ]] && [[ ${res} -ne "2" ]]; then echo failed to create vlan interface for kind-node && exit ${res} ; fi
  if [ ${IP_FAMILY} == "ipv4" ]; then
    docker exec ${node} ip addr add ${VLANID1_IP} dev ${DEFAULT_INTERFACE}.${VLANID1}
    docker exec ${node} ip addr add ${VLANID2_IP} dev ${DEFAULT_INTERFACE}.${VLANID2}
  elif [ ${IP_FAMILY} == "ipv6" ]; then
    docker exec ${node} ip addr add ${VLANID1_IP6} dev ${DEFAULT_INTERFACE}.${VLANID1}
    docker exec ${node} ip addr add ${VLANID2_IP6} dev ${DEFAULT_INTERFACE}.${VLANID2}
  elif [ ${IP_FAMILY} == "dual" ]; then
    docker exec ${node} ip addr add ${VLANID1_IP} dev ${DEFAULT_INTERFACE}.${VLANID1}
    docker exec ${node} ip addr add ${VLANID2_IP} dev ${DEFAULT_INTERFACE}.${VLANID2}
    docker exec ${node} ip addr add ${VLANID1_IP6} dev ${DEFAULT_INTERFACE}.${VLANID1}
    docker exec ${node} ip addr add ${VLANID2_IP6} dev ${DEFAULT_INTERFACE}.${VLANID2}
  else
    echo "error ip familt, the value of IP_FAMILY must be of ipv4,ipv6 or dual." && exit 1
  fi
  docker exec ${node} ip link set ${DEFAULT_INTERFACE}.${VLANID1} up
  docker exec ${node} ip link set ${DEFAULT_INTERFACE}.${VLANID2} up
  VLANID1_IP=172.100.0.200/16
  VLANID2_IP=172.200.0.200/16
  VLANID1_IP6=fd00:172:100::200/64
  VLANID2_IP6=fd00:172:200::200/64
done

# run a test container as a vlan gateway and client
# note: ip address of this container should be consist with spiderpool's gateway
#
containerID=`docker run -itd  --name ${VLAN_GATEWAY_CONTAINER} --network kind --cap-add=NET_ADMIN --privileged centos/tools`
docker exec ${containerID} ip link add link ${DEFAULT_INTERFACE} name ${DEFAULT_INTERFACE}.${VLANID1} type vlan id ${VLANID1}
docker exec ${containerID} ip link add link ${DEFAULT_INTERFACE} name ${DEFAULT_INTERFACE}.${VLANID2} type vlan id ${VLANID2}
docker exec ${containerID} ip link set ${DEFAULT_INTERFACE}.${VLANID1} up
docker exec ${containerID} ip link set ${DEFAULT_INTERFACE}.${VLANID2} up
if [ ${IP_FAMILY} == "ipv4" ]; then
    docker exec ${containerID} ip addr add 172.100.0.1 dev ${DEFAULT_INTERFACE}.${VLANID1}
    docker exec ${containerID} ip addr add 172.200.0.1 dev ${DEFAULT_INTERFACE}.${VLANID2}
elif [ ${IP_FAMILY} == "ipv6" ]; then
    docker exec ${containerID}  sysctl -w net.ipv6.conf.${DEFAULT_INTERFACE}/${VLANID1}.disable_ipv6
    docker exec ${containerID}  sysctl -w net.ipv6.conf.${DEFAULT_INTERFACE}/${VLANID2}.disable_ipv6
    docker exec ${containerID} ip addr add fd00:172:100::1 dev ${DEFAULT_INTERFACE}.${VLANID1}
    docker exec ${containerID} ip addr add fd00:172:200::1 dev ${DEFAULT_INTERFACE}.${VLANID2}
elif [ ${IP_FAMILY} == "dual" ]; then
    docker exec ${containerID}  sysctl -w net.ipv6.conf.${DEFAULT_INTERFACE}/${VLANID1}.disable_ipv6=0
    docker exec ${containerID}  sysctl -w net.ipv6.conf.${DEFAULT_INTERFACE}/${VLANID2}.disable_ipv6=0
    docker exec ${containerID} ip addr add 172.100.0.1 dev ${DEFAULT_INTERFACE}.${VLANID1}
    docker exec ${containerID} ip addr add 172.200.0.1 dev ${DEFAULT_INTERFACE}.${VLANID2}
    docker exec ${containerID} ip addr add fd00:172:100::1 dev ${DEFAULT_INTERFACE}.${VLANID1}
    docker exec ${containerID} ip addr add fd00:172:200::1 dev ${DEFAULT_INTERFACE}.${VLANID2}
else
    echo "error ip family, the value of IP_FAMILY must be of ipv4,ipv6 or dual." && exit 1
fi

echo -e "\033[35m Succeed to create vlan interface: ${DEFAULT_INTERFACE}.${VLANID1}、 ${DEFAULT_INTERFACE}.${VLANID2} in kind-node \033[0m"
