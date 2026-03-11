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

This guide explains how to access the Kubernetes cluster (K3s) from your local machine using `kubectl`.

### 1. Prerequisites

Ensure `kubectl` is installed on your local machine.
- [Install Tools | Kubernetes](https://kubernetes.io/docs/tasks/tools/)

### 2. Setup Kubeconfig

Download the kubeconfig file from the master node to your local machine.
*Note: This command will overwrite your existing `~/.kube/config`.*

```bash
# Create the directory if it doesn't exist
mkdir -p ~/.kube

# Fetch the config from the master node
ssh master "sudo cat /etc/rancher/k3s/k3s.yaml" > ~/.kube/config
```

### 3. Establish SSH Tunnel

Since the API server is running on a private network(`10.10.0.11`), you must establish an SSH tunnel to access it securely.

Open a terminal and run the following command. Keep this window open while working with cluster.

```bash
ssh -L 6443:localhost:6443 master
```

### Verification

in a separate terminal window, verify the connection:
```bash
kubectl get nodes
```

## Argo CD Access

The Argo CD portal can be accessed securely using a port forward.

### 1. Prerequisite: API Tunnel

Ensure you have established the SSH tunnel to the Kubernetes API server (as described in the "Kubernetes Access" section):

```bash
ssh -L 6443:localhost:6443 master
```

### 2. Port Forward Argo CD Server

In a new terminal window, establish a port forward to the Argo CD server service:

```bash
kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443
```

### 3. Access the Portal

Open your browser and navigate to:
[https://localhost:8080/](https://localhost:8080/)

### 4. Login Credentials

- **Username:** `admin`
- **Initial Password:** Retrieve the password using this command:

```bash
# macOS/Linux
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Windows (PowerShell)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```
