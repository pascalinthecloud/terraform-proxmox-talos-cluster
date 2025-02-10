---
title: Setup talos cluster
description: A guide for setting up talos cluster with this module.
---

```terraform
module "talos_cluster" {
  source = "git::https://github.com/pascalinthecloud/terraform-proxmox-talos-cluster.git?ref=main"
  cluster = {
    vm_base_id     = 700
    name           = "cluster-prod"
    datastore      = "local-lvm"
    node           = "pve01"
    config_patches = [file("${path.module}/config_patch.yaml")]
  }
  image = {
    version    = "v1.9.3"
    extensions = ["qemu-guest-agent", "iscsi-tools", "util-linux-tools"]
  }
  network = {
    cidr        = "10.10.100.0/24"
    gateway     = "10.10.100.1"
    dns_servers = ["10.0.10.1", "1.1.1.1"]
    vlan_id     = 1100
  }
  controlplane = {
    count = 1
    specs = {
      cpu    = 2
      memory = 6192
      disk   = 80
    }
  }
  worker = {
    count = 2
    specs = {
      cpu    = 2
      memory = 6192
      disk   = 80
    }
  }
}
```

That's our base configuration. Beginning from the top, we specify all cluster-related information, like the `vm_base_id` (needed for Proxmox), the datastore, and the node the VMs are placed on. We can specify additional config patches, for example, for installing extra manifests and activating some Talos-specific configs. For more infos about configuration patches look at the [talos documentation](https://www.talos.dev/v1.9/talos-guides/configuration/patching/).

We can deploy single worker and control plane nodes on a different Proxmox host by specifying overrides or adjust datastore, network configuration, CPU, and RAM configurations as needed.

```terraform
module "talos_cluster" {
  // ...existing code...
  controlplane = {
    count = 1
    specs = {
      cpu    = 2
      memory = 6192
      disk   = 80
    }
    overrides = {
      "controlplane-1" = {
        node = "pve02"
        network = {
          cidr        = "10.10.100.0/24"
          ip_address  = "10.10.100.150"
          gateway     = "10.10.100.1"
          dns_servers = ["10.0.10.1", "1.1.1.1"]
          vlan_id     = 1100
        }
      }
    }
  }
  worker = {
    count = 2
    specs = {
      cpu    = 2
      memory = 6192
      disk   = 80
    }
    overrides = {
      "worker-1" = {
        cpu  = 1
        node = "pve02"
        network = {
          cidr        = "10.10.100.0/24"
          ip_address  = "10.10.100.160"
          gateway     = "10.10.100.1"
          dns_servers = ["10.0.10.1", "1.1.1.1"]
          vlan_id     = 1100
        }
      }
    }
  }
}
```
After running terraform apply, the cluster is ready for use. Simply retrieve the kubeconfig for Kubernetes access and the talosconfig for managing Talos nodes.

```bash
terraform output --raw kubeconfig > cluster.kubeconfig
terraform output --raw talosconfig > cluster.talosconfig
```
