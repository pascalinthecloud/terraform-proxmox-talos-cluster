output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
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
  value = data.talos_cluster_health.this
}
