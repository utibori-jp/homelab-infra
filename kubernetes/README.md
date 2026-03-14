# Kubernetes Architecture

## Cluster Overview

This diagram illustrates the homelab's Kubernetes networking and infrastructure setup, including external access via Tailscale and the internal namespace structure.

```mermaid
flowchart TD
    subgraph External_Network ["External Network"]
        Client["External Laptop<br/>(Tailscale Client)"]
        Tailnet(("Tailscale (Tailnet)<br/>Virtual Network"))
    end

    subgraph Home_Server ["Home Server (Proxmox VE)<br/>IP: proxmox.uchibori-home.duckdns.org"]
        
        subgraph Nodes ["Ubuntu Node VMs (Node 1〜3)<br/>IP Range: 10.10.0.x"]
            
            subgraph K8s_Cluster ["K8s Cluster<br/>Service CIDR: 10.43.0.0/16"]
                
                subgraph ns_tailscale ["Namespace: tailscale"]
                    TS_Operator["tailscale-operator Pod"]
                end

                subgraph ns_argocd ["Namespace: argocd"]
                    ArgoCD_Server["Argo CD Server<br/>Cluster IP: 10.43.110.253<br/>External DNS: argocd-argo-cd-argocd-server.tail078c12.ts.net"]
                end

                subgraph ns_longhorn ["Namespace: longhorn-system"]
                    Longhorn_Frontend["Longhorn Frontend<br/>Cluster IP: 10.43.112.98<br/>External DNS: longhorn-system-longhorn-frontend.tail078c12.ts.net"]
                end
                
            end
        end
    end

    Client <-->|Connects via| Tailnet
    Tailnet <-->|VPN Tunnel| TS_Operator
    TS_Operator -->|Routes to| ArgoCD_Server
    TS_Operator -->|Routes to| Longhorn_Frontend
```

## Infrastructure Details

### 1. External Access
- **Tailscale (Tailnet):** Virtual network connecting external clients to the cluster.
- **External Laptop:** Pre-configured Tailscale client.

### 2. Kubernetes Resources
- **Argo CD Server:**
  - **External DNS:** `argocd-argo-cd-argocd-server.tail078c12.ts.net`
  - **Cluster IP:** `10.43.110.253`
- **Longhorn Frontend:**
  - **External DNS:** `longhorn-system-longhorn-frontend.tail078c12.ts.net`
  - **Cluster IP:** `10.43.112.98`

### 3. Physical / VM Infrastructure
- **Proxmox Host:** `proxmox.uchibori-home.duckdns.org`
- **Ubuntu Node VMs:** IP Range `10.10.0.x`
- **K8s Service CIDR:** `10.43.0.0/16`

---

## Original Conceptual Diagram
![Architecture Diagram](image.png)
