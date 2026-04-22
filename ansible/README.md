# Ansible

Manages configuration of the k3s cluster nodes.

## Runtime Environment

**On Windows, run this from WSL.** Native Windows Python/Ansible does not expand `~` in the SSH config correctly and does not handle `ProxyJump` properly.

## Usage

```bash
# Connectivity check
ansible all -m ping

# Apply k3s configuration
ansible-playbook playbooks/k3s-config.yaml
```

## Scope

Initial node setup (OS install, k3s install, etc.) is currently done manually and is not yet covered by Ansible. To be added later.

## Playbooks

| File | Purpose |
|---|---|
| `playbooks/k3s-config.yaml` | Manages `/etc/rancher/k3s/config.yaml` on the control-plane (disables ServiceLB, etc.) |
| `playbooks/setup-master.yaml` | Installs tooling on the control-plane (Helm, etc.) |
