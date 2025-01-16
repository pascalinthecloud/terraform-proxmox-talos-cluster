# terraform-proxmox-talos-cluster
Terraform module to provision a Kubernetes cluster on Proxmox using Talos Linux. Automates node creation, Talos configuration, and integration with Proxmox, providing a secure and lightweight environment for homelabs or production use. Ideal for streamlined Kubernetes setup and management.

## Example Usage
```hcl
module "k8s_cluster" {
  source       = "../modules/k8s_cluster"
  vm_base_id   = 700
  cluster_name = "homelab.cluster"
  datastore    = "local-lvm"
  node         = "pve01"

  image = {
    version    = "v1.9.1"
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
## Get kubeconfig and talosconfig

```bash
terraform output kubeconfig > cluster.kubeconfig 
terraform output talosconfig > cluster.talosconfig
```