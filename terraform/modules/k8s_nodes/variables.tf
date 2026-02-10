################################################################################
# General
################################################################################
variable "node_count" {
  description = "The number of K8s nodes to provision."
  type        = number
  default     = 3
}

variable "name_prefix" {
  description = "VM name prefix (e.g. k8s-node, db-server)."
  type        = string
  default     = "k8s-node"
}

################################################################################
# Resources (Compute & Storage)
################################################################################

variable "pve_node" {
  description = "The name of the Proxmox node where the VMs will be provisioned."
  type        = string
  default     = "pve"
}

variable "vm_id_start" {
  description = "The starting ID for the VMs (e.g., 200 will result in 200, 201, 202...)."
  type        = number
  default     = 200
}

variable "template_vm_id" {
  description = "The ID of the source VM template to clone from."
  type        = number
  default     = 103
}

variable "cpu_cores" {
  description = "Number of CPU cores per node."
  type        = number
  default     = 4
}

variable "memory_size" {
  description = "Memory size per node (MB)."
  type        = number
  default     = 6144
}

variable "datastore_id" {
  description = "Proxmox datastore ID (e.g., local-lvm, local-zfs)."
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Disk size per node (GB)."
  type        = number
  default     = 64
}

################################################################################
# Network
################################################################################

variable "network_bridge" {
  description = "The name of the network bridge (or SDN VNet) to attach the network interface to."
  type        = string
  default     = ""
}

variable "ip_subnet_prefix" {
  description = "The IPv4 subnet prefix (e.g., '10.10.0') used for static IP assignment."
  type        = string
  default     = "10.10.0"
}

variable "ip_start_num" {
  description = "The starting number for the last octet of the IP address (e.g., 11 results in .11, .12...)."
  type        = number
  default     = 11
}

variable "gateway" {
  description = "The IPv4 address of the default gateway."
  type        = string
  default     = "10.10.0.1"
}

################################################################################
# Authentication
################################################################################

variable "ssh_public_key" {
  description = "SSH public key to register for the VM user."
  type        = string
  sensitive   = true
}
