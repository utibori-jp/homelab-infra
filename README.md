## SSH Access

The Kubernetes nodes utilize a private network (`10.10.0.0/24`) and are not directly accessible from the outside. To access them, you must use the Proxmox host (`pve`) as a **Jump Host (Bastion)**.

### 1. Prerequisite: Copy SSH Key to Proxmox

To enable password-less jumping, register your public key with the Proxmox host:

```bash
# Replace ~/.ssh/id_ed25519.pub with your actual public key path
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@192.168.0.100
```

### 2. Configure Local SSH Config

Add the following configuration to your local ~/.ssh/config file. This allows you to SSH directly into the nodes by names, automatically routing through the jump host.

```
# --- Proxmox Jump Host ---
Host pve
    HostName 192.168.0.100
    User root
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

# --- Kubernetes Control Plane ---
Host master
    HostName 10.10.0.11
    User ubuntu
    ProxyJump pve
    IdentityFile ~/.ssh/id_ed25519

# --- Kubernetes Worker Nodes ---
Host worker1
    HostName 10.10.0.12
    User ubuntu
    ProxyJump pve
    IdentityFile ~/.ssh/id_ed25519

Host worker2
    HostName 10.10.0.13
    User ubuntu
    ProxyJump pve
    IdentityFile ~/.ssh/id_ed25519
```

### 3. Usage

Once configured, you can access the nodes using their short names:

```bash
ssh master     # Access Control Plane
ssh worker1    # Access Worker Node 1
ssh worker2    # Access Worker Node 2
```
