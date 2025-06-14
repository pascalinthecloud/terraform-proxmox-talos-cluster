variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name           = string                       # The name of the cluster
    config_patches = optional(list(string), [])   # List of configuration patches to apply to the Talos machine configuration
    node           = string                       # Default node to deploy the vms on
    datastore      = string                       # Default datastore to deploy the vms on
    vm_base_id     = number                       # The first VM ID for Proxmox VMs, with subsequent IDs counted up from it
    install_disk   = optional(string, "/dev/sda") # The disk to install Talos on
    ip_base_offset = optional(number, 10)         # Offset for IP addresses of the cluster nodes
  })
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.cluster.name))
    error_message = "The cluster_name must only contain letters, numbers, and dashes (-)."
  }
}

variable "controlplane" {
  description = "Specification of controlplane nodes"
  type = object({
    count = number
    specs = object({
      cpu    = number
      memory = number
      disk   = number
    })
    overrides = optional(map(object({
      datastore    = optional(string, null)
      vm_base_id   = optional(number, null)
      node         = optional(string, null)
      cpu          = optional(number, null)
      memory       = optional(number, null)
      disk         = optional(number, null)
      install_disk = optional(string, null)
      network = optional(object({
        ip_address = string
        cidr       = string
        gateway    = string
        vlan_id    = optional(number, null)
      }), null)
    })), {})
  })
}

variable "image" {
  description = "Variable to define the image configuration for Talos machines"
  type = object({
    version           = string
    extensions        = list(string)
    factory_url       = optional(string, "https://factory.talos.dev")
    arch              = optional(string, "amd64")
    platform          = optional(string, "nocloud")
    proxmox_datastore = optional(string, "local")
  })
}

variable "network" {
  description = "Network configuration for nodes"
  type = object({
    bridge      = optional(string, "vmbr0") # The bridge to use for the network interface
    cidr        = string
    gateway     = string
    dns_servers = list(string)
    vlan_id     = optional(number, null)
  })
}

variable "worker" {
  description = "Specification of worker nodes"
  type = object({
    count = number
    specs = object({
      ip_offset = optional(number, 10) # Offset for IP addresses of worker nodes
      cpu       = number
      memory    = number
      disk      = number
    })
    overrides = optional(map(object({
      datastore    = optional(string, null)
      vm_base_id   = optional(number, null)
      node         = optional(string, null)
      cpu          = optional(number, null)
      memory       = optional(number, null)
      disk         = optional(number, null)
      install_disk = optional(string, null)
      network = optional(object({
        ip_address = string
        cidr       = string
        gateway    = string
        vlan_id    = optional(number, null)
      }), null)
    })), {})
  })
}

