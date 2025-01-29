<!-- BEGIN_TF_DOCS -->
# terraform-proxmox-talos-cluster
Terraform module to provision a Kubernetes cluster on Proxmox using Talos Linux. Automates node creation, Talos configuration, and integration with Proxmox, providing a secure and lightweight environment for homelabs or production use. Ideal for streamlined Kubernetes setup and management.

## Example

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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.69.0 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.7.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.2 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.69.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.7.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster configuration | <pre>object({<br/>    name           = string                       # The name of the cluster<br/>    config_patches = list(string)                 # List of configuration patches to apply to the Talos machine configuration<br/>    node           = string                       # Default node to deploy the vms on<br/>    datastore      = string                       # Default datastore to deploy the vms on<br/>    vm_base_id     = number                       # The first VM ID for Proxmox VMs, with subsequent IDs counted up from it<br/>    install_disk   = optional(string, "/dev/sda") # The disk to install Talos on<br/>  })</pre> | n/a | yes |
| <a name="input_controlplane"></a> [controlplane](#input\_controlplane) | Specification of controlplane nodes | <pre>object({<br/>    count = number<br/>    specs = object({<br/>      cpu    = number<br/>      memory = number<br/>      disk   = number<br/>    })<br/>    overrides = optional(map(object({<br/>      datastore    = optional(string, null)<br/>      node         = optional(string, null)<br/>      cpu          = optional(number, null)<br/>      memory       = optional(number, null)<br/>      disk         = optional(number, null)<br/>      install_disk = optional(string, null)<br/>      network = optional(object({<br/>        ip_address = string<br/>        cidr       = string<br/>        gateway    = string<br/>        vlan_id    = optional(number, null)<br/>      }), null)<br/>    })), {})<br/>  })</pre> | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Variable to define the image configuration for Talos machines | <pre>object({<br/>    version           = string<br/>    extensions        = list(string)<br/>    factory_url       = optional(string, "https://factory.talos.dev")<br/>    arch              = optional(string, "amd64")<br/>    platform          = optional(string, "nocloud")<br/>    proxmox_datastore = optional(string, "local")<br/>  })</pre> | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network configuration for nodes | <pre>object({<br/>    cidr        = string<br/>    gateway     = string<br/>    dns_servers = list(string)<br/>    vlan_id     = optional(number, null)<br/>  })</pre> | n/a | yes |
| <a name="input_worker"></a> [worker](#input\_worker) | Specification of worker nodes | <pre>object({<br/>    count = number<br/>    specs = object({<br/>      cpu    = number<br/>      memory = number<br/>      disk   = number<br/>    })<br/>    overrides = optional(map(object({<br/>      datastore    = optional(string, null)<br/>      node         = optional(string, null)<br/>      cpu          = optional(number, null)<br/>      memory       = optional(number, null)<br/>      disk         = optional(number, null)<br/>      install_disk = optional(string, null)<br/>      network = optional(object({<br/>        ip_address = string<br/>        cidr       = string<br/>        gateway    = string<br/>        vlan_id    = optional(number, null)<br/>      }), null)<br/>    })), {})<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | n/a |
| <a name="output_talos_cluster_health"></a> [talos\_cluster\_health](#output\_talos\_cluster\_health) | n/a |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | n/a |
<!-- END_TF_DOCS -->