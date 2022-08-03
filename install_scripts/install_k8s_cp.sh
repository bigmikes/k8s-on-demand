#!/bin/bash
set -ex

CONTROL_NODE_NAME=$1

cat <<EOT > kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: 1.22.1
controlPlaneEndpoint: "${CONTROL_NODE_NAME}:6443"
networking:
  podSubnet: 192.168.0.0/16
EOT

kubeadm init --config=kubeadm-config.yaml --upload-certs

wget https://docs.projectcalico.org/manifests/calico.yaml

mkdir -p /home/$CONTROL_NODE_NAME/.kube
cp -i /etc/kubernetes/admin.conf /home/$CONTROL_NODE_NAME/.kube/config
chown $(id -u $CONTROL_NODE_NAME):$(id -g $CONTROL_NODE_NAME) /home/$CONTROL_NODE_NAME/.kube/config

kubectl apply -f calico.yaml

apt-get install bash-completion -y
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> /home/$CONTROL_NODE_NAME/.bashrc