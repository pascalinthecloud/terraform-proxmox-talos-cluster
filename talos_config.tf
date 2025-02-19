# Creating secrets for Talos machines (controlplane and worker)
resource "talos_machine_secrets" "this" {}

# Talos machine configuration for controlplane nodes
data "talos_machine_configuration" "controlplane" {
  cluster_name = var.cluster.name

  cluster_endpoint = "https://${local.controlplanes[keys(local.controlplanes)[0]].ip_address}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

# Talos machine configuration for worker nodes
data "talos_machine_configuration" "worker" {
  cluster_name = var.cluster.name

  cluster_endpoint = "https://${local.controlplanes[keys(local.controlplanes)[0]].ip_address}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

# Talos client configuration for the Kubernetes cluster
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for _, controlplane in local.controlplanes : controlplane.ip_address]
}

# Apply Talos machine configuration to controlplane VMs
resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [proxmox_virtual_environment_vm.controlplane]
  for_each   = local.controlplanes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.ip_address
  config_patches = concat([
    templatefile("${path.module}/templates/install-disk-and-hostname.yaml.tmpl", {
      hostname     = each.value.hostname
      install_disk = each.value.install_disk
    }),
    file("${path.module}/templates/cp-scheduling.yaml"),
    ],
    var.cluster.config_patches
  )
}

# Apply Talos machine configuration to worker VMs
resource "talos_machine_configuration_apply" "worker" {
  depends_on = [proxmox_virtual_environment_vm.worker]
  for_each   = local.workers

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.ip_address
  config_patches = concat([
    templatefile("${path.module}/templates/install-disk-and-hostname.yaml.tmpl", {
      hostname     = each.value.hostname
      install_disk = each.value.install_disk
    })],
    var.cluster.config_patches
  )
}

# Bootstrap Talos on the first controlplane node to initialize the Talos cluster
resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplanes[keys(local.controlplanes)[0]].ip_address
  endpoint             = local.controlplanes[keys(local.controlplanes)[0]].ip_address

}

# Retrieve the Kubernetes kubeconfig
resource "talos_cluster_kubeconfig" "this" {
  depends_on = [talos_machine_bootstrap.this]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplanes[keys(local.controlplanes)[0]].ip_address
  endpoint             = local.controlplanes[keys(local.controlplanes)[0]].ip_address
}

# Waits for the Talos cluster to be ready /talos_cluster_health)
# tflint-ignore: terraform_unused_declarations
data "talos_cluster_health" "this" {
  depends_on = [
    talos_machine_bootstrap.this,
    talos_machine_configuration_apply.worker,
    talos_machine_configuration_apply.controlplane
  ]

  client_configuration = data.talos_client_configuration.this.client_configuration
  control_plane_nodes  = [for _, controlplane in local.controlplanes : controlplane.ip_address]
  worker_nodes         = [for _, worker in local.workers : worker.ip_address]
  endpoints            = data.talos_client_configuration.this.endpoints

  timeouts = {
    read = "5m"
  }
}
