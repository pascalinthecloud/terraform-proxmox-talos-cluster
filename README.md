<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.2 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.69.0 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.69.0 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_download_file.this](https://registry.terraform.io/providers/bpg/proxmox/0.69.0/docs/resources/virtual_environment_download_file) | resource |
| [proxmox_virtual_environment_vm.controlplane](https://registry.terraform.io/providers/bpg/proxmox/0.69.0/docs/resources/virtual_environment_vm) | resource |
| [proxmox_virtual_environment_vm.worker](https://registry.terraform.io/providers/bpg/proxmox/0.69.0/docs/resources/virtual_environment_vm) | resource |
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.0/docs/resources/cluster_kubeconfig) | resource |
| [talos_image_factory_schematic.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.0/docs/resources/image_factory_schematic) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.0/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.7.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_configuration_apply.worker](https://registry.terraform.io/providers/siderolabs/talos/0.7.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.0/docs/resources/machine_secrets) | resource |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.0/docs/data-sources/client_configuration) | data source |
| [talos_cluster_health.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.0/docs/data-sources/cluster_health) | data source |
| [talos_image_factory_extensions_versions.this](https://registry.terraform.io/providers/siderolabs/talos/0.7.0/docs/data-sources/image_factory_extensions_versions) | data source |
| [talos_machine_configuration.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.7.0/docs/data-sources/machine_configuration) | data source |
| [talos_machine_configuration.worker](https://registry.terraform.io/providers/siderolabs/talos/0.7.0/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_controlplane"></a> [controlplane](#input\_controlplane) | Specification of controlplane nodes | <pre>object({<br/>    count = number<br/>    specs = object({<br/>      cpu    = number<br/>      memory = number<br/>      disk   = number<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_datastore"></a> [datastore](#input\_datastore) | Proxmox datastore ID | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Variable to define the image configuration for Talos machines | <pre>object({<br/>    version           = string<br/>    extensions        = list(string)<br/>    factory_url       = optional(string, "https://factory.talos.dev")<br/>    arch              = optional(string, "amd64")<br/>    platform          = optional(string, "nocloud")<br/>    proxmox_datastore = optional(string, "local")<br/>  })</pre> | n/a | yes |
| <a name="input_install_disk"></a> [install\_disk](#input\_install\_disk) | Install disk for talos | `string` | `"/dev/sda"` | no |
| <a name="input_network"></a> [network](#input\_network) | Network configuration for nodes | <pre>object({<br/>    cidr        = string<br/>    gateway     = string<br/>    dns_servers = list(string)<br/>    vlan_id     = optional(number, null)<br/>  })</pre> | n/a | yes |
| <a name="input_node"></a> [node](#input\_node) | Proxmox node name for VM deployment | `string` | n/a | yes |
| <a name="input_vm_base_id"></a> [vm\_base\_id](#input\_vm\_base\_id) | The first VM ID for Proxmox VMs, with subsequent IDs counted up from it | `number` | n/a | yes |
| <a name="input_worker"></a> [worker](#input\_worker) | Specification of worker nodes | <pre>object({<br/>    count = number<br/>    specs = object({<br/>      cpu    = number<br/>      memory = number<br/>      disk   = number<br/>    })<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | n/a |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | n/a |
<!-- END_TF_DOCS -->