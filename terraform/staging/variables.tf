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
  description = "The Proxmox node to place the VM on."
  type        = string
  default     = "pve"
}

################################################################################
# Talos
################################################################################

variable "talos_version" {
  description = "Talos version for the boot image and the installer."
  type        = string
  default     = "v1.14.5"
}

variable "cluster_name" {
  type    = string
  default = "staging"
}

################################################################################
# VM
################################################################################

variable "vm_id" {
  type    = number
  default = 300
}

variable "vm_name" {
  type    = string
  default = "stg-talos-1"
}

variable "cpu_cores" {
  type    = number
  default = 2
}

variable "memory_size" {
  description = "Memory size (MB)."
  type        = number
  default     = 4096
}

variable "disk_size" {
  description = "Disk size (GB)."
  type        = number
  default     = 32
}

################################################################################
# Network
################################################################################

# Shares the production vnet so the existing subnet router covers it.
variable "network_bridge" {
  type    = string
  default = "k8sVnet"
}

variable "node_ip" {
  type    = string
  default = "10.10.0.51"
}

variable "gateway" {
  type    = string
  default = "10.10.0.1"
}

variable "dns_servers" {
  type    = list(string)
  default = ["192.168.0.1", "8.8.8.8"]
}
