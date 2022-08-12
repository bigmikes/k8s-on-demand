output "public_ip_control_nodes" {
  value = google_compute_global_address.ext_lb_ip.address
}

output "public_ip_worker_nodes" {
  value = module.worker_nodes.public_ip_nodes
}