---
title: HA VIP Configuration
description: Learn how to configure High Availability VIP for your Talos cluster.
---

## Overview

The module now supports High Availability VIP (Virtual IP) configuration for multi-controlplane Talos clusters. When multiple control planes are configured, the HA VIP feature is automatically enabled and configured.

## How It Works

### Automatic Enablement

The HA VIP is automatically enabled when you configure **more than one control plane** (`controlplane.count > 1`). When enabled:

1. A virtual IP address is automatically assigned to the cluster
2. The Kubernetes API endpoint uses this VIP instead of a single control plane IP
3. Control planes are configured with a shared IP on the specified network interface (default `eth0`)
4. All nodes point to this VIP as the cluster endpoint, enabling transparent failover

### IP Address Assignment

By default, the HA VIP is auto-generated and assigned to the first available IP address after the last control plane:

```
With ip_base_offset = 10 and 3 control planes:
- controlplane-1: 10.10.100.10
- controlplane-2: 10.10.100.11
- controlplane-3: 10.10.100.12
- ha_vip:        10.10.100.13 (automatically assigned)
```

### Custom VIP Address

You can specify a custom HA VIP address and the network interface to bind it to:

```hcl
cluster = {
  name             = "talos-cluster"
  node             = "pve"
  datastore        = "local-lvm"
  vm_base_id       = 5000
  ha_vip           = "10.10.100.50"  # Custom VIP address
  ha_vip_interface = "eth0"          # Interface to bind VIP to (default: eth0)
}
```

### How it works

1.  **Shared IP**: The VIP is configured as a shared IP on the specified network interface (default: `eth0`) of each control plane node.
2.  **Etcd Election**: Talos uses etcd to elect a leader among the control planes.
3.  **Owner**: The elected leader "owns" the VIP and responds to ARP requests for it.
4.  **Failover**: If the leader fails, a new leader is elected, and the VIP moves to the new leader automatically.

This provides a Layer 2 High Availability setup for the Kubernetes API endpoint.


## Usage Example

### Single Control Plane (HA VIP Disabled)

```hcl
module "k8s_cluster" {
  source = "git::https://github.com/pascalinthecloud/terraform-proxmox-talos-cluster.git"

  cluster = {
    name           = "homelab"
    vm_base_id     = 700
    datastore      = "local-lvm"
    node           = "pve01"
  }

  controlplane = {
    count = 1  # Single control plane, HA VIP not used
    specs = {
      cpu    = 2
      memory = 4096
      disk   = 50
    }
  }

  # ... rest of configuration ...
}
```

### Multiple Control Planes (HA VIP Enabled)

```hcl
module "k8s_cluster" {
  source = "git::https://github.com/pascalinthecloud/terraform-proxmox-talos-cluster.git"

  cluster = {
    name           = "homelab"
    vm_base_id     = 700
    datastore      = "local-lvm"
    node           = "pve01"
    # ha_vip is optional - will be auto-generated if not specified
  }

  controlplane = {
    count = 3  # Three control planes, HA VIP automatically enabled
    specs = {
      cpu    = 2
      memory = 4096
      disk   = 50
    }
  }

  # ... rest of configuration ...
}
```

### With Custom VIP Address

```hcl
module "k8s_cluster" {
  source = "git::https://github.com/pascalinthecloud/terraform-proxmox-talos-cluster.git"

  cluster = {
    name           = "homelab"
    vm_base_id     = 700
    datastore      = "local-lvm"
    node           = "pve01"
    ha_vip         = "10.10.100.50"  # Custom VIP address
  }

  controlplane = {
    count = 3
    specs = {
      cpu    = 2
      memory = 4096
      disk   = 50
    }
  }

  # ... rest of configuration ...
}
```

## Outputs

The module exposes three new outputs related to HA VIP:

- **`ha_vip_enabled`**: Boolean indicating whether HA VIP is enabled
- **`ha_vip`**: The HA VIP address (null if HA is disabled)
- **`cluster_endpoint`**: The complete Kubernetes API endpoint URL

```hcl
# Example outputs
output "cluster_endpoint" {
  value = module.k8s_cluster.cluster_endpoint
  # Output: "https://10.10.100.13:6443" (when HA is enabled)
}
```

## Technical Details

### Configuration Patch

When HA is enabled, the module applies a configuration patch to all control planes that:

1. Configures the VIP as a shared IP on the specified network interface (default `eth0`)
2. Configures the cluster control plane endpoint to use the VIP
3. Enables Talos to manage VIP failover via etcd elections

The patch is automatically included in the configuration and uses the template: `templates/ha-vip.yaml.tmpl`

### Network Interface

The HA VIP is bound to a physical network interface on each control plane as a shared IP. This allows the VIP to be claimed by the active leader node.

## Failover Behavior

With HA VIP enabled:

- **Single control plane failure**: Talos automatically elects a new leader, which claims the VIP.
- **All control planes down**: The VIP is unavailable.
- **Network isolation**: If a control plane loses network connectivity, it loses its leadership, and another node takes over the VIP.

## Notes

- This implementation provides Layer 2 redundancy for the VIP using ARP.
- The VIP must be within the same subnet as your control planes.
- You must ensure `ha_vip_interface` matches the actual interface name on your Talos nodes.
- The auto-generated VIP ensures no IP conflicts by placing it after all control plane IPs.
