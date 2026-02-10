################################################################################
# SDN VNet
################################################################################

output "vnet_id" {
  description = "The unique identifier of the SDN VNet resource."
  value       = proxmox_virtual_environment_sdn_vnet.k8s_vnet.id
}

output "vnet_zone" {
  description = "The SDN Zone ID where this VNet belongs."
  value       = proxmox_virtual_environment_sdn_vnet.k8s_vnet.zone
}

################################################################################
# Network Configuration Details
################################################################################

output "vnet_tag" {
  description = "The VLAN tag associated with the VNet (if configured)."
  value       = try(proxmox_virtual_environment_sdn_vnet.k8s_vnet.tag, null)
}
