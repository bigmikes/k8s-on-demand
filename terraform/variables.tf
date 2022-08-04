variable "credential_file_path" {
  type    = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "control_nodes_map" {
  type    = map(string)
  default = {
    "control1" = "10.0.0.2"
  }
}

variable "worker_nodes_map" {
  type    = map(string)
  default = {
    "node1" = "10.0.0.3"
    "node2" = "10.0.0.4"
  }
}