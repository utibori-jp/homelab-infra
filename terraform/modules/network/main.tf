resource "proxmox_virtual_environment_sdn_zone_simple" "k8s_zone" {
  id    = "k8sZone"
  nodes = ["pve"]
  mtu   = 1500

  ipam = "pve"
}

resource "proxmox_virtual_environment_sdn_vnet" "k8s_vnet" {
  id   = "k8sVnet"
  zone = proxmox_virtual_environment_sdn_zone_simple.k8s_zone.id

  depends_on = [
    proxmox_virtual_environment_sdn_applier.finalizer
  ]
}

resource "proxmox_virtual_environment_sdn_subnet" "k8s_subnet" {
  cidr    = var.cidr
  vnet    = proxmox_virtual_environment_sdn_vnet.k8s_vnet.id
  gateway = var.gateway

  snat = true

  depends_on = [
    proxmox_virtual_environment_sdn_applier.finalizer
  ]
}

resource "proxmox_virtual_environment_sdn_applier" "vnet_applier" {
  depends_on = [
    proxmox_virtual_environment_sdn_zone_simple.k8s_zone,
    proxmox_virtual_environment_sdn_vnet.k8s_vnet,
    proxmox_virtual_environment_sdn_subnet.k8s_subnet
  ]
}

resource "proxmox_virtual_environment_sdn_applier" "finalizer" {
}
