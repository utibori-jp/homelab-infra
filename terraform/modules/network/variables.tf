variable "cidr" {
  type        = string
  default     = "10.10.0.0/24"
  description = "cidr for this vnet"
}

variable "gateway" {
  type        = string
  default     = "10.10.0.1"
  description = "The gateway ip whicn connects with proxmox and this separated network"
}
