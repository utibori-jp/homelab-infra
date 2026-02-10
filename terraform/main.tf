# ------------------------------------------------------------------------------
# Network Module
# ------------------------------------------------------------------------------
module "network" {
  source = "./modules/network"
}

# ------------------------------------------------------------------------------
# Kubernetes Nodes (Master & Workers)
# ------------------------------------------------------------------------------
module "k8s-nodes" {
  source = "./modules/k8s_nodes"

  # --- Dependencies ---
  network_bridge = module.network.vnet_id
  ssh_public_key = var.ssh_public_key

  # --- Compute Resources ---
  cpu_cores   = 4
  memory_size = 6144
  disk_size   = 64

  # --- Cluster Scaling ---
  node_count   = var.k8s_node_count
  vm_id_start  = 200
  ip_start_num = 11

  # --- Naming ---
  name_prefix = "home-lab"
}
