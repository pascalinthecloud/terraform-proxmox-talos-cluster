---
title: IPv6 Dual-Stack
description: How to configure IPv6 dual-stack networking for your Talos cluster with Cilium.
---

## Overview

This guide shows how to configure IPv6 dual-stack networking for your Talos cluster. Dual-stack gives every pod and service both an IPv4 and IPv6 address, which is useful for environments that need IPv6 connectivity.

Dual-stack requires:
- Cilium configured with IPv6 support (see [Cilium CNI guide](/guides/cilium/))
- Custom pod and service subnets via Talos config patches
- IPv6 forwarding enabled on all nodes

## Module Configuration

Enable Cilium and apply dual-stack config patches:

```hcl
module "talos_cluster" {
  source = "git::https://github.com/pascalinthecloud/terraform-proxmox-talos-cluster.git"

  cluster = {
    name           = "homelab-prod"
    vm_base_id     = 900
    datastore      = "local-lvm"
    node           = "pve01"
    config_patches = [file("${path.module}/config_patch.yaml")]
  }

  image = {
    version    = "v1.12.5"
    extensions = ["qemu-guest-agent", "iscsi-tools", "util-linux-tools"]
  }

  network = {
    cidr        = "10.10.110.0/24"
    gateway     = "10.10.110.1"
    dns_servers = ["10.0.10.1", "1.1.1.1"]
    vlan_id     = 1110
  }

  controlplane = {
    count = 3
    specs = {
      cpu    = 4
      memory = 10240
      disk   = 150
    }
  }

  worker = {
    count = 3
    specs = {
      cpu    = 4
      memory = 8096
      disk   = 150
    }
  }

  cilium = {
    enabled = true
  }
}
```

## Config Patch for Dual-Stack

The module handles CNI and kube-proxy configuration when `cilium.enabled = true`. For dual-stack you need an additional config patch file (`config_patch.yaml`) that defines the IPv6 subnets and enables IPv6 forwarding:

```yaml
machine:
  kubelet:
    extraArgs:
      rotate-server-certificates: "true"
  sysctls:
    net.ipv6.conf.all.forwarding: "1"

cluster:
  network:
    # Dual-stack Pod networks (overlay, not tied to your node VLAN)
    podSubnets:
      - 10.244.0.0/16
      - fd9f:81c8:3c17:1204::/64

    # Dual-stack Service networks (ClusterIP range)
    serviceSubnets:
      - 10.96.0.0/12
      - fd9f:81c8:3c17:1300::/112

  controllerManager:
    extraArgs:
      node-cidr-mask-size-ipv6: "80"

  extraManifests:
    - https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
    - https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Key settings:

| Setting | Purpose |
|---------|---------|
| `net.ipv6.conf.all.forwarding: "1"` | Enables IPv6 packet forwarding on all nodes |
| `podSubnets` | Defines both IPv4 and IPv6 CIDR ranges for pod IPs |
| `serviceSubnets` | Defines both IPv4 and IPv6 CIDR ranges for ClusterIP services |
| `node-cidr-mask-size-ipv6: "80"` | Splits the `/64` pod subnet into `/80` chunks per node (supports up to 65536 nodes) |

## Cilium Helm Values for Dual-Stack

Enable IPv6 in your Cilium Helm values file:

```yaml
ipam:
  mode: kubernetes

ipv4:
  enabled: true

ipv6:
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
  enabled: true
  relay:
    enabled: true
  ui:
    enabled: true
```

The only difference from a single-stack setup is `ipv6.enabled: true`. Cilium automatically detects the dual-stack pod and service subnets from the Kubernetes API.

## Choosing IPv6 Subnets

Use [ULA (Unique Local Address)](https://en.wikipedia.org/wiki/Unique_local_address) ranges (`fd00::/8`) for private dual-stack clusters:

- **Pod subnet**: Pick a `/64` block, e.g., `fd9f:81c8:3c17:1204::/64`
- **Service subnet**: Pick a `/112` block, e.g., `fd9f:81c8:3c17:1300::/112`

The `/112` for services matches the IPv4 convention of ~65k service IPs. The `/64` for pods is split per-node by the `node-cidr-mask-size-ipv6` setting.

## Verifying Dual-Stack

After deploying Cilium and scheduling workloads:

```bash
# Check nodes have dual-stack addresses
kubectl get nodes -o wide

# Check pods have both IPv4 and IPv6
kubectl get pods -o wide

# Check services get dual-stack ClusterIPs
kubectl get svc -A
```

## MetalLB with Dual-Stack

If using MetalLB for LoadBalancer services, configure IPv6 address pools:

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: internal-ipv6
  namespace: metallb-system
spec:
  addresses:
    - fd9f:81c8:3c17:1100::200-fd9f:81c8:3c17:1100::27f
```

## Notes

- IPv6 subnets for pods and services are overlay networks — they don't need to match your physical VLAN addressing.
- The `net.ipv6.conf.all.forwarding` sysctl is required on all nodes for IPv6 pod traffic to flow.
- If your environment has no IPv6 router advertisements, you don't need to worry about SLAAC conflicts with ULA addresses.
- Dual-stack config patches are applied via `config_patches` alongside the module's automatic Cilium patches — they don't conflict.
