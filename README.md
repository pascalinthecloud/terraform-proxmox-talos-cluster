# terraform-proxmox-talos-cluster
Terraform module to provision a Kubernetes cluster on Proxmox using Talos Linux. Automates node creation, Talos configuration, and integration with Proxmox, providing a secure and lightweight environment for homelabs or production use. Ideal for streamlined Kubernetes setup and management.

## Example Usage
```bash
module "k8s_cluster" {
  source       = "../modules/k8s_cluster"
  vm_base_id   = 700
  cluster_name = "homelab.cluster"
  datastore    = "local-lvm"
  node         = "pve01"

  image = {
    version      = "v1.9.1"
    schematic_id = "88d1f7a5c4f1d3aba7df787c448c1d3d008ed29cfb34af53fa0df4336a56040b"
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
      memory = 4096
      disk   = 50
    }
  }

  worker = {
    count = 2
    specs = {
      cpu    = 2
      memory = 6192
      disk   = 50
    }
  }
}

```
