#!/bin/bash
set -ex

PATH_TO_GCP_CRED_FILE=$(realpath $1)

cd terraform 
terraform init && terraform apply -auto-approve -var="credential_file_path=$PATH_TO_GCP_CRED_FILE"

sleep 30

CONTROL_NODES_IP=$(terraform output -json public_ip_control_nodes | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]')
WORKER_NODES_IP=$(terraform output -json public_ip_worker_nodes | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]')

IFS='=' read -ra CONTROL_NODES_INFO <<< "$CONTROL_NODES_IP"

scp -o "ConnectionAttempts 10" -o "StrictHostKeyChecking no" -i .ssh/google_compute_engine ../install_scripts/install_k8s.sh ${CONTROL_NODES_INFO[0]}@${CONTROL_NODES_INFO[1]}:~
ssh -o "StrictHostKeyChecking no" -i .ssh/google_compute_engine ${CONTROL_NODES_INFO[0]}@${CONTROL_NODES_INFO[1]} "sudo ./install_k8s.sh ${CONTROL_NODES_INFO[1]} ${CONTROL_NODES_INFO[0]}"
scp -o "StrictHostKeyChecking no" -i .ssh/google_compute_engine ../install_scripts/install_k8s_cp.sh ${CONTROL_NODES_INFO[0]}@${CONTROL_NODES_INFO[1]}:~
ssh -o "StrictHostKeyChecking no" -i .ssh/google_compute_engine ${CONTROL_NODES_INFO[0]}@${CONTROL_NODES_INFO[1]} "sudo ./install_k8s_cp.sh ${CONTROL_NODES_INFO[0]}"

while IFS='=' read -ra WORKER_NODES_INFO; do
  scp -o "ConnectionAttempts 10" -o "StrictHostKeyChecking no" -i .ssh/google_compute_engine ../install_scripts/install_k8s.sh ${WORKER_NODES_INFO[0]}@${WORKER_NODES_INFO[1]}:~
  ssh -n -o "StrictHostKeyChecking no" -i .ssh/google_compute_engine ${WORKER_NODES_INFO[0]}@${WORKER_NODES_INFO[1]} "sudo ./install_k8s.sh ${CONTROL_NODES_INFO[1]} ${CONTROL_NODES_INFO[0]}"
  echo "Installed K8s in worked node ${WORKER_NODES_INFO[0]}@${WORKER_NODES_INFO[1]}"
done <<< "$WORKER_NODES_IP"

JOIN_COMMAND=$(ssh -o "StrictHostKeyChecking no" -i .ssh/google_compute_engine ${CONTROL_NODES_INFO[0]}@${CONTROL_NODES_INFO[1]} "sudo kubeadm token create --print-join-command")

while IFS='=' read -ra WORKER_NODES_INFO; do
  ssh -n -o "StrictHostKeyChecking no" -i .ssh/google_compute_engine ${WORKER_NODES_INFO[0]}@${WORKER_NODES_INFO[1]} "sudo $JOIN_COMMAND"
done <<< "$WORKER_NODES_IP"

echo "Login to control node via ssh -o \"StrictHostKeyChecking no\" -i terraform/.ssh/google_compute_engine ${CONTROL_NODES_INFO[0]}@${CONTROL_NODES_INFO[1]}"