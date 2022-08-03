#!/bin/bash
set -ex

CONTROL_NODE_IP=$1
CONTROL_NODE_NAME=$2

apt-get update 
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef
apt-get install -y docker.io 
apt-get install -y vim

cat <<EOT > /etc/docker/daemon.json
{
   "exec-opts":[
      "native.cgroupdriver=systemd"
   ],
   "log-driver":"json-file",
   "log-opts":{
      "max-size":"100m"
   },
   "storage-driver":"overlay2"
}
EOT
systemctl restart docker ; sudo systemctl status docker

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list;
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -;
apt-get update -y
apt-get install -y kubeadm=1.22.1-00 kubelet=1.22.1-00 kubectl=1.22.1-00 
apt-mark hold kubeadm kubelet kubectl
apt-get install -y nfs-common

echo "${CONTROL_NODE_IP} ${CONTROL_NODE_NAME}" > hosts.tmp
echo "$(cat /etc/hosts)" >> hosts.tmp
mv hosts.tmp /etc/hosts
