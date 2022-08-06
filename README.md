# k8s-on-demand
Deploy a Kubernetes cluster on GCP in one command.

## Intro

Mainly for learning purposes, I needed to create, destroy and recreate a Kubernetes cluster quite often. So I decided to automate it with [Terraform](https://www.terraform.io/) and [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).

Currently, the Terraform templates deploy 3 VMs in GCP's `us-central1` region. Then, the script uses `kubeadm` to initialize 1 control node and 2 worker nodes.

## How To Use

Simply run the `deploy.sh` script by passing your [GCP credential file](https://cloud.google.com/docs/authentication/getting-started).

For example:
```bash
./deploy.sh k8s-course-351222-dec129ebe138.json
```

Run the `destroy.sh` script when you want to destroy the Kubernetes cluster and related cloud resources:

```bash
./destroy.sh k8s-course-351222-dec129ebe138.json
```

## Warning
The cluster that is going to be deployed **is not** production ready. Please don't use it *as-is* for your production deployment.