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

resource "helm_release" "cilium" {
  count            = var.cilium.enabled ? 1 : 0
  name             = "cilium"
  repository       = "https://helm.cilium.io"
  chart            = "cilium"
  version          = var.cilium.version
  namespace        = "kube-system"
  cleanup_on_fail  = true
  create_namespace = false

  values = var.cilium.values != null ? var.cilium.values : [local.cilium_default_values]

  depends_on = [data.http.talos_health]
}
