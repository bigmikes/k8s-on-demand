variable "host_to_ip_map" {
  type = map(string)
}

variable "subnet_name" {
  type = string
}

variable "ssh_key" {
  type = string
}

resource "google_compute_instance" "k8s_nodes" {
  for_each = var.host_to_ip_map
  name         = each.key
  machine_type = "e2-standard-2"

  tags = ["allow-all"]

  boot_disk {
    initialize_params {
      size  = 20
      image = "ubuntu-1804-bionic-v20220505"
    }
  }

  metadata = {
    ssh-keys = "${each.key}:${var.ssh_key}"
  }

  network_interface {
    subnetwork = var.subnet_name
    network_ip = each.value
    access_config {
      // Ephemeral public IP
    }
  }
}

output "public_ip_nodes" {
  value = {
    for k, node in google_compute_instance.k8s_nodes : node.name => node.network_interface.0.access_config.0.nat_ip
  }
}