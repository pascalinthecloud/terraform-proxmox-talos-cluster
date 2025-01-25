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
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_config_patches"></a> [config\_patches](#input\_config\_patches) | List of configuration patches to apply to the Talos machine configuration | `list(string)` | n/a | yes |
| <a name="input_controlplane"></a> [controlplane](#input\_controlplane) | Specification of controlplane nodes | <pre>object({<br/>    count = number<br/>    specs = object({<br/>      cpu    = number<br/>      memory = number<br/>      disk   = number<br/>    })<br/>    overrides = optional(map(object({<br/>      node   = optional(string, null)<br/>      cpu    = optional(number, null)<br/>      memory = optional(number, null)<br/>      disk   = optional(number, null)<br/>      network = optional(object({<br/>        ip_address = string<br/>        cidr       = string<br/>        gateway    = string<br/>        vlan_id    = optional(number, null)<br/>      }), null)<br/>    })), {})<br/>  })</pre> | n/a | yes |
| <a name="input_datastore"></a> [datastore](#input\_datastore) | Proxmox datastore ID | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Variable to define the image configuration for Talos machines | <pre>object({<br/>    version           = string<br/>    extensions        = list(string)<br/>    factory_url       = optional(string, "https://factory.talos.dev")<br/>    arch              = optional(string, "amd64")<br/>    platform          = optional(string, "nocloud")<br/>    proxmox_datastore = optional(string, "local")<br/>  })</pre> | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network configuration for nodes | <pre>object({<br/>    cidr        = string<br/>    gateway     = string<br/>    dns_servers = list(string)<br/>    vlan_id     = optional(number, null)<br/>  })</pre> | n/a | yes |
| <a name="input_node"></a> [node](#input\_node) | Proxmox node name for VM deployment | `string` | n/a | yes |
| <a name="input_vm_base_id"></a> [vm\_base\_id](#input\_vm\_base\_id) | The first VM ID for Proxmox VMs, with subsequent IDs counted up from it | `number` | n/a | yes |
| <a name="input_worker"></a> [worker](#input\_worker) | Specification of worker nodes | <pre>object({<br/>    count = number<br/>    specs = object({<br/>      cpu    = number<br/>      memory = number<br/>      disk   = number<br/>    })<br/>    overrides = optional(map(object({<br/>      node   = optional(string, null)<br/>      cpu    = optional(number, null)<br/>      memory = optional(number, null)<br/>      disk   = optional(number, null)<br/>      network = optional(object({<br/>        ip_address = string<br/>        cidr       = string<br/>        gateway    = string<br/>        vlan_id    = optional(number, null)<br/>      }), null)<br/>    })), {})<br/>  })</pre> | n/a | yes |
| <a name="input_install_disk"></a> [install\_disk](#input\_install\_disk) | Install disk for talos | `string` | `"/dev/sda"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | n/a |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | n/a |
<!-- END_TF_DOCS -->