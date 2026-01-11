output "talosconfig" {
  description = "Talos configuration file for the cluster"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes kubeconfig for the cluster"
  value = {
    client_key  = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
    client_cert = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
    ca_cert     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
    host        = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
    kubeconfig  = talos_cluster_kubeconfig.this.kubeconfig_raw
  }
  sensitive = true
}

output "talos_cluster_health" {
  description = "Health status of the Talos cluster, can be used for other ressources to depend on"
  value       = data.talos_cluster_health.this
}

output "talos_image_schematic_id" {
  description = "ID of the Talos image schematic"
  value       = talos_image_factory_schematic.this.id
}

output "ha_vip_enabled" {
  description = "Whether HA VIP is enabled for the cluster"
  value       = local.ha_vip_enabled
}

output "ha_vip" {
  description = "HA VIP address for the cluster (when HA is enabled)"
  value       = local.ha_vip
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint for the cluster"
  value       = local.cluster_endpoint
}