resource "proxmox_virtual_environment_vm" "k8s_nodes" {
  # ----------------------------------------------------------------------------
  # General Configuration
  # ----------------------------------------------------------------------------
  count     = var.node_count
  name      = "${var.name_prefix}-${count.index + 1}"
  node_name = var.pve_node
  vm_id     = var.vm_id_start + count.index

  # ----------------------------------------------------------------------------
  # Template & Clone Settings
  # ----------------------------------------------------------------------------
  clone {
    vm_id = var.template_vm_id
  }

  # ----------------------------------------------------------------------------
  # Compute Resources (CPU & Memory)
  # ----------------------------------------------------------------------------
  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.memory_size
  }

  # ----------------------------------------------------------------------------
  # Storage
  # ----------------------------------------------------------------------------
  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size
    file_format  = "raw"
  }

  # ----------------------------------------------------------------------------
  # Network
  # ----------------------------------------------------------------------------
  network_device {
    model  = "virtio"
    bridge = var.network_bridge
  }

  # ----------------------------------------------------------------------------
  # Cloud-Init & Initialization
  # ----------------------------------------------------------------------------
  initialization {

    # Network Interface Configuration
    ip_config {
      ipv4 {
        # Construct IP: e.g., "10.10.0" + "." + "11" + "/24"
        address = "${var.ip_subnet_prefix}.${var.ip_start_num + count.index}/24"
        gateway = var.gateway
      }
    }

    # User & Auth
    user_account {
      keys = [var.ssh_public_key]
    }
  }
}
