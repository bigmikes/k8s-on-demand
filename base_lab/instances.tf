module "control_nodes" {
  source       = "./modules/k8s_node"
  subnet_name = google_compute_subnetwork.vpc_subnet.name
  ssh_key = tls_private_key.ssh.public_key_openssh
  host_to_ip_map = var.control_nodes_map
}

module "worker_nodes" {
  source       = "./modules/k8s_node"
  subnet_name = google_compute_subnetwork.vpc_subnet.name
  ssh_key = tls_private_key.ssh.public_key_openssh
  host_to_ip_map = var.worker_nodes_map
}