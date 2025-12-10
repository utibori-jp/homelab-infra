resource "proxmox_vm_qemu" "k8s_master" {
  name        = "k8s-master"
  target_node = "pve"
  clone       = "ubuntu-2204-cloudinit-template"
  cores       = 2
  memory      = 4096

  ipconfig = "ip=192.168.1.10/24, gw=192.168.1.1"
  sshkeys  = file("~/.ssh/id_rsa.pub")
}

resource "proxmox_vm_qemu" "k3s_workers" {
  count = 2

  name = "k3s-worker-0${count.index + 1}"

  target_node = "pve"

  clone = "k8s-base-template"

  # 基本設定
  cores    = 2
  sockets  = 1
  memory   = 4096
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot    = 0
    size    = "32G"
    type    = "scsi"
    storage = "local-lvm"
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  os_type = "cloud-init"

  sshkeys = <<EOF
  // TODO: set sshkeys
  EOF

  ciuser     = "ubuntu"
  cipassword = "password"

  ipconfig0 = "ip=192.168.0.2${count.index + 1}/24,gw=192.168.0.1"
}
