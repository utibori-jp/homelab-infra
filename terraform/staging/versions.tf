terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.118.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.12.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.pve_endpoint
  api_token = var.pve_api_token
  insecure  = true
}
