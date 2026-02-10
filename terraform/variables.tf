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

################################################################################
# Global Access Configuration
################################################################################

variable "ssh_public_key" {
  description = "The SSH public key to be injected into the VMs via Cloud-Init."
  type        = string
  sensitive   = true
}

################################################################################
# Cluster Configuration (Optional)
################################################################################

variable "k8s_node_count" {
  type        = number
  default     = 3
  description = "Number of Kubernetes worker nodes to provision."
}
