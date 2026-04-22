# homelab-infra

Infrastructure-layer repository for a Proxmox + k3s homelab managed with GitOps (Argo CD). This repo provisions the VMs, configures the k3s nodes, and bootstraps the in-cluster controllers (Argo CD, Tailscale operator). Applications running on top of the cluster are managed in a separate repository.

## Architecture

Two-repository GitOps layout:

| Repository | Visibility | Scope |
|---|---|---|
| `homelab-infra` (this repo) | private | Terraform, Ansible, Argo CD bootstrap, Tailscale operator |
| [`homelab-services`](https://github.com/utibori-jp/homelab-services) | public | Application layer (App-of-Apps pattern), self-authored Helm charts |

Argo CD self-manages from `kubernetes/system/argo-cd`. Once bootstrapped, the `root` Application in `homelab-services` takes over application deployments.

## Directory Layout

```
homelab-infra/
├── terraform/            # Proxmox VE VM provisioning (k3s node VMs)
├── ansible/              # Node configuration (k3s config, Helm, Longhorn prerequisites)
└── kubernetes/
    ├── bootstrap/        # Argo CD Application manifests (argo-cd, tailscale-operator)
    └── system/           # Helm charts referenced by the bootstrap Applications
        ├── argo-cd/
        └── tailscale/
```

Sub-directory documentation:
- [ansible/README.md](./ansible/README.md)
- [kubernetes/README.md](./kubernetes/README.md)

## Cluster

- k3s v1.34.3+k3s3
- 3 nodes: `home-lab-1` (control-plane), `home-lab-2`, `home-lab-3` (workers)
- VM network: `10.10.0.0/24` on Proxmox
- Access: Tailscale (tailnet `tail078c12.ts.net`)
- Tailscale HTTPS certificates: enabled
- Argo CD: v3.3.0

## Bootstrap Flow

1. Provision node VMs with Terraform (`terraform/`).
2. Install k3s on each node (currently manual; not yet Ansible-managed).
3. Apply node-level configuration with Ansible (`ansible/`).
4. Install Argo CD from the local chart:
   ```bash
   sudo -E KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
     helm install argocd kubernetes/system/argo-cd \
     --namespace argocd --create-namespace
   ```
5. Hand over control to Argo CD (self-management) and sync the Tailscale operator:
   ```bash
   sudo kubectl apply -f kubernetes/bootstrap/argo-cd.yaml
   sudo kubectl apply -f kubernetes/bootstrap/tailscale.yaml
   ```
6. Apply the `root` Application from the `homelab-services` repo to deploy the application layer.

## Accessing the Cluster

All access goes through Tailscale. Connect to the tailnet first.

### SSH

```bash
ssh ubuntu@home-lab-1
```

### kubectl / helm on the control-plane

`kubectl` picks up `/etc/rancher/k3s/k3s.yaml` automatically via `sudo`; `helm` needs it set explicitly.

```bash
sudo kubectl get nodes
sudo -E KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm list -A
```

### Web UIs

Ingresses are provisioned by the Tailscale operator (see `homelab-services/charts/tailscale-ingresses`):

| Service | URL |
|---|---|
| Argo CD | https://argocd.tail078c12.ts.net |
| Longhorn | https://longhorn.tail078c12.ts.net |
| Vikunja | https://vikunja.tail078c12.ts.net |

### Argo CD initial password

```bash
sudo kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```
