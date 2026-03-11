# reccomend to generate new ssh-key for this project
ssh-keygen -t ed25519 -C "homelab" -f ~/.ssh/id_ed25519

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

## Kubernetes Access

This guide explains how to access the Kubernetes cluster (K3s) from your local machine using `kubectl`. There are two ways to connect: **via Tailscale (Standard)** and **via SSH Tunnel (Emergency/Initial Setup)**.

### 1. Prerequisites

Ensure `kubectl` is installed on your local machine.

* [Install Tools | Kubernetes](https://kubernetes.io/docs/tasks/tools/)

### 2. Setup Kubeconfig

Download the kubeconfig file from the master node to your local machine.
*Note: This command will overwrite your existing `~/.kube/config`.*

```bash
# Create the directory if it doesn't exist
mkdir -p ~/.kube

# Fetch the config from the master node
ssh master "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config

# Fix permissions (macOS/Linux only)
chmod 600 ~/.kube/config

```

### 3. Choose Your Access Method

#### Method A: Tailscale Access (Recommended for Daily Use)

If the Tailscale Operator is running and you are connected to Tailnet, you can access the API server directly without any SSH tunnels.

1. **Edit your `~/.kube/config`**:
Change the `server` address to the master node's private IP (`10.10.0.11`).
```yaml
clusters:
- cluster:
    server: https://10.10.0.11:6443  # Update this line

```


2. **Verify**:
```bash
kubectl get nodes

```



#### Method B: SSH Tunnel (Emergency / Initial Setup)

Use this method if Tailscale is not yet configured or is down.

1. **Edit your `~/.kube/config`**:
Ensure the `server` address points to `localhost`.
```yaml
clusters:
- cluster:
    server: https://localhost:6443

```

2. **Establish SSH Tunnel**:
Keep this terminal window open.
```bash
ssh -L 6443:localhost:6443 master

```

3. **Verify**:
In a separate terminal:
```bash
kubectl get nodes

```

## Argo CD Access

The Argo CD portal can be accessed securely using a port forward.

### 1. Port Forward Argo CD Server

You can run this directly if you are connected via Tailscale (Method A) or while the SSH tunnel (Method B) is active.

```bash
kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443

```

### 2. Access the Portal

Open your browser and navigate to:
[https://localhost:8080/](https://www.google.com/search?q=https://localhost:8080/)
*(Note: You may see a certificate warning; this is expected for the default self-signed certificate.)*

### 3. Login Credentials

* **Username:** `admin`
* **Initial Password:** Retrieve the password using this command:

```bash
# macOS/Linux
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Windows (PowerShell)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

```
