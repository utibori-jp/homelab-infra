resource "proxmox_vm_qemu" "k8s_master" {
    name = "k8s-master"
    target_node = "pve"
    clone = "ubuntu-2204-cloudinit-template"
    cores = 2
    memory = 4096

    ipconfig = "ip=192.168.1.10/24, gw=192.168.1.1"
    sshkeys = file("~/.ssh/id_rsa.pub")
}
