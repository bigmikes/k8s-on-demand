# module "control_nodes" {
#   source       = "./modules/k8s_node"
#   subnet_name = google_compute_subnetwork.vpc_subnet.name
#   ssh_key = tls_private_key.ssh.public_key_openssh
#   host_to_ip_map = var.control_nodes_map
# }

resource "google_compute_instance_template" "cp-node-template" {
  name         = "cp-node-template"
  machine_type = "e2-standard-2"
  tags = ["allow-all"]

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.vpc_subnet.id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "ubuntu-1804-bionic-v20220505"
    auto_delete  = true
    boot         = true
    disk_size_gb = 20
  }

  metadata = {
    ssh-keys = "control:${tls_private_key.ssh.public_key_openssh}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "cp-instance-group" {
  name     = "cp-instance-group"
  named_port {
    name = "tcp-k8s-api"
    port = 6443
  }
  version {
    instance_template = google_compute_instance_template.cp-node-template.id
    name              = "primary"
  }
  base_instance_name = "cp-vm"
  target_size        = 3
}

module "worker_nodes" {
  source       = "./modules/k8s_node"
  subnet_name = google_compute_subnetwork.vpc_subnet.name
  ssh_key = tls_private_key.ssh.public_key_openssh
  host_to_ip_map = var.worker_nodes_map
}