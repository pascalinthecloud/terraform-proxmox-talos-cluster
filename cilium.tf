locals {
  cilium_default_values = <<-YAML
    ipam:
      mode: kubernetes

    ipv4:
      enabled: true

    kubeProxyReplacement: true

    k8sServiceHost: localhost
    k8sServicePort: 7445

    bpf:
      hostLegacyRouting: true

    securityContext:
      capabilities:
        ciliumAgent:
          - CHOWN
          - KILL
          - NET_ADMIN
          - NET_RAW
          - IPC_LOCK
          - SYS_ADMIN
          - SYS_RESOURCE
          - DAC_OVERRIDE
          - FOWNER
          - SETGID
          - SETUID
        cleanCiliumState:
          - NET_ADMIN
          - SYS_ADMIN
          - SYS_RESOURCE

    cgroup:
      autoMount:
        enabled: false
      hostRoot: /sys/fs/cgroup

    hubble:
      enabled: false
  YAML
}

data "helm_template" "cilium" {
  count     = var.cilium.enabled ? 1 : 0
  name      = "cilium"
  namespace = "kube-system"

  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = var.cilium.version

  values = var.cilium.values != null ? var.cilium.values : [local.cilium_default_values]
}

data "kubectl_file_documents" "cilium" {
  count   = var.cilium.enabled ? 1 : 0
  content = data.helm_template.cilium[0].manifest
}

resource "kubectl_manifest" "cilium" {
  for_each   = var.cilium.enabled ? data.kubectl_file_documents.cilium[0].manifests : {}
  yaml_body  = each.value
  apply_only = true
  depends_on = [data.http.talos_health]
}
