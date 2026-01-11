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
3. Control planes are configured with a dummy network interface to bind the VIP
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

You can specify a custom HA VIP address by setting it in the cluster configuration:

```hcl
cluster = {
  name           = "my-cluster"
  # ... other config ...
  ha_vip = "10.10.100.50"  # Custom VIP address
}
```

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

1. Creates a dummy network interface for the VIP
2. Configures the cluster control plane endpoint to use the VIP
3. Allows keepalived or another L3 redundancy solution to manage VIP failover

The patch is automatically included in the configuration and uses the template: `templates/ha-vip.yaml.tmpl`

### Network Interface

The HA VIP is bound to a dummy network interface on each control plane. This allows the VIP to be moved between control planes without physical network reconfiguration.

## Failover Behavior

With HA VIP enabled:

- **Single control plane failure**: Kubernetes API requests are automatically redirected to a healthy control plane
- **All control planes down**: The VIP is unavailable, but no reconfiguration is needed when they come back online
- **Network isolation**: If a control plane loses network connectivity, the VIP should be managed by an external L3 redundancy solution (like keepalived)

## Notes

- The dummy interface approach provides L2 redundancy for the VIP
- For true L3 failover, consider deploying keepalived or a similar tool in your cluster
- The VIP must be within the same subnet as your control planes
- The auto-generated VIP ensures no IP conflicts by placing it after all control plane IPs
