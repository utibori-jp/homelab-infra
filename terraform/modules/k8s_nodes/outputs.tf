################################################################################
# VM Identifiers
################################################################################

output "vm_ids" {
  description = "The IDs of the created Kubernetes nodes."
  value       = proxmox_virtual_environment_vm.k8s_nodes[*].vm_id
}

output "vm_names" {
  description = "The names of the created Kubernetes nodes."
  value       = proxmox_virtual_environment_vm.k8s_nodes[*].name
}

################################################################################
# Network Details
################################################################################

output "vm_ipv4_addresses" {
  description = "The list of IPv4 addresses assigned to the nodes (flattened)."
  value       = flatten(proxmox_virtual_environment_vm.k8s_nodes[*].ipv4_addresses)
}
