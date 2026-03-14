---
title: Cilium CNI
description: How to configure and deploy Cilium as the CNI for your Talos cluster.
---

## Overview

[Cilium](https://cilium.io/) is a modern, eBPF-based CNI that provides networking, observability, and security for Kubernetes. This module supports Cilium as a drop-in replacement for the default Flannel CNI.

When `cilium.enabled = true`, the module automatically:

1. Configures Talos for Cilium:
   - Disables the default CNI (`cluster.network.cni.name: none`)
   - Disables kube-proxy (`cluster.proxy.disabled: true`) — Cilium replaces it with eBPF
   - Enables kubePrism (`machine.features.kubePrism`) on port `7445` — provides a local API proxy so Cilium can reach the API server via `localhost:7445`

2. Deploys Cilium via `helm_release` after the cluster health check passes

## Provider Setup

The module requires a configured `helm` provider to deploy Cilium. Configure it using the module's kubeconfig output:

```hcl
provider "helm" {
  kubernetes {
    host                   = module.talos_cluster.kubeconfig.host
    client_certificate     = base64decode(module.talos_cluster.kubeconfig.client_cert)
    client_key             = base64decode(module.talos_cluster.kubeconfig.client_key)
    cluster_ca_certificate = base64decode(module.talos_cluster.kubeconfig.ca_cert)
  }
}
```

## Basic Usage

Enable Cilium with default settings:

```hcl
module "talos_cluster" {
  source = "git::https://github.com/pascalinthecloud/terraform-proxmox-talos-cluster.git"

  cluster = {
    name       = "homelab-prod"
    vm_base_id = 700
    datastore  = "local-lvm"
    node       = "pve01"
  }

  image = {
    version    = "v1.12.5"
    extensions = ["qemu-guest-agent", "iscsi-tools", "util-linux-tools"]
  }

  network = {
    cidr        = "10.10.100.0/24"
    gateway     = "10.10.100.1"
    dns_servers = ["10.0.10.1", "1.1.1.1"]
    vlan_id     = 1100
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

This deploys Cilium with sensible defaults for Talos (see [Default Values](#default-values)).

## Custom Values

Override the defaults by providing your own Helm values:

```hcl
cilium = {
  enabled = true
  version = "1.19.1"
  values  = [file("${path.module}/helm_values/cilium.yaml")]
}
```

### Custom Values Example

A `cilium.yaml` with Hubble and IPv6 enabled:

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

## Default Values

When no custom values are provided, the module uses these Talos-compatible defaults:

| Setting | Value | Why |
|---------|-------|-----|
| `ipam.mode` | `kubernetes` | Standard IPAM mode |
| `ipv4.enabled` | `true` | IPv4 networking |
| `kubeProxyReplacement` | `true` | Cilium replaces kube-proxy (disabled by the module) |
| `k8sServiceHost` | `localhost` | Uses kubePrism local proxy (enabled by the module) |
| `k8sServicePort` | `7445` | kubePrism port configured by the module |
| `bpf.hostLegacyRouting` | `true` | Required for compatibility with some network setups |
| `cgroup.autoMount.enabled` | `false` | Talos mounts cgroups itself |
| `cgroup.hostRoot` | `/sys/fs/cgroup` | Talos cgroup path |
| `securityContext` | (capabilities list) | Required capabilities for Cilium on Talos |
| `hubble.enabled` | `false` | Disabled by default to reduce resource usage |

## Health Check

The module uses an HTTP health check against the Kubernetes API server (`/version` endpoint) instead of `talos_cluster_health`. This is important because the standard health check requires a CNI to be running, which creates a chicken-and-egg problem when using Cilium.

The health check polls `https://<controlplane>:6443/version` with 60 retries at 5-second intervals (5 minutes total), giving the API server enough time to become available after bootstrap. Cilium is deployed only after this health check passes.

## Notes

- The cluster will show `NotReady` nodes until Cilium is deployed — this is expected.
- Cilium must be deployed before any other workloads can be scheduled.
- When using HA VIP (`controlplane.count > 1`), kubePrism ensures Cilium can always reach the API server locally, even during VIP failover.
- For IPv6 dual-stack, see the [IPv6 Dual-Stack guide](/guides/dual_stack_ipv6/).
