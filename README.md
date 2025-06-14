<!-- BEGIN_TF_DOCS -->
# terraform-proxmox-talos-cluster
A Terraform module for provisioning a Kubernetes cluster on Proxmox using Talos Linux. This module automates node creation, Talos configuration, and Proxmox integration, offering a secure, lightweight, and efficient environment for homelabs or production use. It simplifies the Kubernetes setup and management process.

Feel free to contact me, open an issue, or contribute to the project. Your feedback and contributions are always welcome! 🤓

## Geting kubeconfig & talosconfig
```bash
terraform output --raw kubeconfig > cluster.kubeconfig
terraform output --raw talosconfig > cluster.talosconfig
```

## Upgrading Talos cluster
First we need get the schematic id from the outputs and use that for upgrading the cluster in order to keep the extensions. 
```bash
talosctl upgrade --image factory.talos.dev/installer/<SCHEMATIC_ID>:v1.9.3 --preserve
```
The preserve option is only needed when wanting to keep files/directories on Talos nodes (for example when using Longhorn/Rook...)

## Example

```hcl
module "k8s_cluster" {
  source = "git::https://github.com/pascalinthecloud/terraform-proxmox-talos-cluster.git?ref=v1.0.0"

  cluster = {
    name           = "homelab.cluster"
    vm_base_id     = 700
    ip_base_offset = 10 # Offset for IP addresses of controlplane and worker nodes
    datastore      = "local-lvm"
    node           = "pve01"
    config_patches = [file("${path.module}/config_patch.yaml")]
  }

  image = {
    version    = "v1.10.4"
    extensions = ["qemu-guest-agent", "iscsi-tools", "util-linux-tools"]
  }

  network = {
    brige       = "vmbr0"
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
      ip_offset = 10 # Offset for IP addresses of worker nodes (from the controlplane IPs)
      cpu       = 2
      memory    = 6192
      disk      = 50
    }
  }
}

# Override example 
module "k8s_cluster_override" {
  source = "git::https://github.com/pascalinthecloud/terraform-proxmox-talos-cluster.git?ref=v1.0.1"

  cluster = {
    name           = "homelab.cluster"
    vm_base_id     = 700
    datastore      = "local-lvm"
    node           = "pve01"
    config_patches = [file("${path.module}/config_patch.yaml")]
  }

  image = {
    version    = "v1.10.4"
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
    overrides = {
      "controlplane-1" = {
        node  = "pve01"
        vm_id = 720
        network = {
          cidr        = "10.10.101.0/24"
          ip_address  = "10.10.101.150"
          gateway     = "10.10.101.1"
          dns_servers = ["10.0.10.1", "1.1.1.1"]
          vlan_id     = 1101
        }
      }
    }
  }

  worker = {
    count = 2
    specs = {
      cpu    = 2
      memory = 6192
      disk   = 50
    }
    overrides = {
      "worker-1" = {
        node = "pve01"
        network = {
          cidr        = "10.10.101.0/24"
          ip_address  = "10.10.101.156"
          gateway     = "10.10.101.1"
          dns_servers = ["10.0.10.1", "1.1.1.1"]
          vlan_id     = 1101
        }
      }
    }
  }

}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | >= 0.69.0, < 1.0.0 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | >= 0.7.0, < 1.0.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.2 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | >= 0.69.0, < 1.0.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | >= 0.7.0, < 1.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | Cluster configuration | <pre>object({<br/>    name           = string                       # The name of the cluster<br/>    config_patches = optional(list(string), [])   # List of configuration patches to apply to the Talos machine configuration<br/>    node           = string                       # Default node to deploy the vms on<br/>    datastore      = string                       # Default datastore to deploy the vms on<br/>    vm_base_id     = number                       # The first VM ID for Proxmox VMs, with subsequent IDs counted up from it<br/>    install_disk   = optional(string, "/dev/sda") # The disk to install Talos on<br/>    ip_base_offset = optional(number, 10)         # Offset for IP addresses of the cluster nodes<br/>  })</pre> | n/a | yes |
| <a name="input_controlplane"></a> [controlplane](#input\_controlplane) | Specification of controlplane nodes | <pre>object({<br/>    count = number<br/>    specs = object({<br/>      cpu    = number<br/>      memory = number<br/>      disk   = number<br/>    })<br/>    overrides = optional(map(object({<br/>      datastore    = optional(string, null)<br/>      vm_id        = optional(number, null)<br/>      node         = optional(string, null)<br/>      cpu          = optional(number, null)<br/>      memory       = optional(number, null)<br/>      disk         = optional(number, null)<br/>      install_disk = optional(string, null)<br/>      network = optional(object({<br/>        ip_address = string<br/>        cidr       = string<br/>        gateway    = string<br/>        vlan_id    = optional(number, null)<br/>      }), null)<br/>    })), {})<br/>  })</pre> | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Variable to define the image configuration for Talos machines | <pre>object({<br/>    version           = string<br/>    extensions        = list(string)<br/>    factory_url       = optional(string, "https://factory.talos.dev")<br/>    arch              = optional(string, "amd64")<br/>    platform          = optional(string, "nocloud")<br/>    proxmox_datastore = optional(string, "local")<br/>  })</pre> | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network configuration for nodes | <pre>object({<br/>    bridge      = optional(string, "vmbr0") # The bridge to use for the network interface<br/>    cidr        = string<br/>    gateway     = string<br/>    dns_servers = list(string)<br/>    vlan_id     = optional(number, null)<br/>  })</pre> | n/a | yes |
| <a name="input_worker"></a> [worker](#input\_worker) | Specification of worker nodes | <pre>object({<br/>    count = number<br/>    specs = object({<br/>      ip_offset = optional(number, 10) # Offset for IP addresses of worker nodes<br/>      cpu       = number<br/>      memory    = number<br/>      disk      = number<br/>    })<br/>    overrides = optional(map(object({<br/>      datastore    = optional(string, null)<br/>      vm_id        = optional(number, null)<br/>      node         = optional(string, null)<br/>      cpu          = optional(number, null)<br/>      memory       = optional(number, null)<br/>      disk         = optional(number, null)<br/>      install_disk = optional(string, null)<br/>      network = optional(object({<br/>        ip_address = string<br/>        cidr       = string<br/>        gateway    = string<br/>        vlan_id    = optional(number, null)<br/>      }), null)<br/>    })), {})<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubernetes kubeconfig for the cluster |
| <a name="output_talos_cluster_health"></a> [talos\_cluster\_health](#output\_talos\_cluster\_health) | Health status of the Talos cluster, can be used for other ressources to depend on |
| <a name="output_talos_image_schematic_id"></a> [talos\_image\_schematic\_id](#output\_talos\_image\_schematic\_id) | ID of the Talos image schematic |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | Talos configuration file for the cluster |

## Repo Activity
![Alt](https://repobeats.axiom.co/api/embed/d5c6fd467a9febbf9bea34fbcd6eb31174975075.svg "Repobeats analytics image")
<!-- END_TF_DOCS -->