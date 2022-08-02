output "public_ip_control_nodes" {
  value = module.control_nodes.public_ip_nodes
}

output "public_ip_worker_nodes" {
  value = module.worker_nodes.public_ip_nodes
}