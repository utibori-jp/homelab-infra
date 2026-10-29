resource "proxmox_virtual_environment_container" "exit_node" {
  node_name     = var.pve_node
  vm_id         = var.ct_id
  description   = "Tailscale exit node"
  tags          = ["tailscale"]
  unprivileged  = true
  start_on_boot = true

  features {
    # systemd in Debian 13 needs it
    nesting = true
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 256
    swap      = 256
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = "debian"
  }

  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }

  # tailscaled needs a TUN device to route exit traffic in kernel mode.
  device_passthrough {
    path = "/dev/net/tun"
  }

  initialization {
    hostname = var.hostname

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      keys = [var.ssh_public_key]
    }
  }
}
