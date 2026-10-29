################################################################################
# Proxmox Provider Configuration
################################################################################

variable "pve_endpoint" {
  description = "The endpoint URL for the Proxmox API (e.g., 'https://192.168.0.100:8006/')."
  type        = string
}

variable "pve_api_token" {
  description = "The API Token for authentication (format: 'USER@REALM!TOKENID=SECRET')."
  type        = string
  sensitive   = true
}

variable "pve_node" {
  type    = string
  default = "pve"
}

################################################################################
# Container
################################################################################

variable "ct_id" {
  type    = number
  default = 110
}

variable "hostname" {
  type    = string
  default = "exit-node"
}

# Already on pve, downloaded through the GUI.
variable "template_file_id" {
  type    = string
  default = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
}

variable "ssh_public_key" {
  description = "SSH public key for root, used by Ansible."
  type        = string
}

################################################################################
# Network
################################################################################

# LAN, not k8sVnet, so exit traffic leaves directly and the node does not
# depend on the cluster.
variable "network_bridge" {
  type    = string
  default = "vmbr0"
}

variable "ip_address" {
  description = "Static IPv4 address in CIDR notation on the LAN (e.g., '192.168.0.110/24')."
  type        = string
}

variable "gateway" {
  type    = string
  default = "192.168.0.1"
}

variable "dns_servers" {
  type    = list(string)
  default = ["192.168.0.1", "8.8.8.8"]
}
