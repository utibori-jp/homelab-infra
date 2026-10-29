# ------------------------------------------------------------------------------
# Talos Image
# ------------------------------------------------------------------------------
resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = [
          "siderolabs/qemu-guest-agent",
          # Longhorn prerequisites
          "siderolabs/iscsi-tools",
          "siderolabs/util-linux-tools",
        ]
      }
    }
  })
}

locals {
  schematic_id    = talos_image_factory_schematic.this.id
  installer_image = "factory.talos.dev/nocloud-installer/${local.schematic_id}:${var.talos_version}"
}

resource "proxmox_download_file" "talos" {
  node_name               = var.pve_node
  datastore_id            = "local"
  content_type            = "iso"
  url                     = "https://factory.talos.dev/image/${local.schematic_id}/${var.talos_version}/nocloud-amd64.raw.zst"
  decompression_algorithm = "zst"
  # PVE rejects .raw, hence .img
  file_name = "talos-${substr(local.schematic_id, 0, 8)}-${var.talos_version}-nocloud-amd64.img"
}

# ------------------------------------------------------------------------------
# VM
# ------------------------------------------------------------------------------
resource "proxmox_virtual_environment_vm" "talos" {
  name            = var.vm_name
  node_name       = var.pve_node
  vm_id           = var.vm_id
  tags            = ["talos", "staging"]
  stop_on_destroy = true

  agent {
    enabled = true
  }

  cpu {
    cores = var.cpu_cores
    # Not "host", so the VM can live-migrate between different CPUs.
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory_size
  }

  scsi_hardware = "virtio-scsi-single"

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    file_id      = proxmox_download_file.talos.id
    file_format  = "raw"
    size         = var.disk_size
    discard      = "on"
    ssd          = true
    iothread     = true
  }

  network_device {
    model  = "virtio"
    bridge = var.network_bridge
  }

  operating_system {
    type = "l26"
  }

  # Talos' nocloud platform reads the network config from this drive.
  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = "${var.node_ip}/24"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }
  }
}

# ------------------------------------------------------------------------------
# Talos Cluster
# ------------------------------------------------------------------------------
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.node_ip}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = "/dev/sda"
          image = local.installer_image
        }
        kubelet = {
          # Longhorn keeps replica data here and needs it visible to the kubelet.
          extraMounts = [{
            destination = "/var/lib/longhorn"
            type        = "bind"
            source      = "/var/lib/longhorn"
            options     = ["bind", "rshared", "rw"]
          }]
        }
      }
      cluster = {
        # Single node, so workloads have to run on the control plane.
        allowSchedulingOnControlPlanes = true
      }
    })
  ]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.node_ip]
  nodes                = [var.node_ip]
}

resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = var.node_ip

  depends_on = [proxmox_virtual_environment_vm.talos]
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.node_ip

  depends_on = [talos_machine_configuration_apply.controlplane]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.node_ip

  depends_on = [talos_machine_bootstrap.this]
}
