variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
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
  })
}

variable "datastore" {
  description = "Proxmox datastore ID"
  type        = string
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

variable "install_disk" {
  description = "Install disk for Talos"
  type        = string
  default     = "/dev/sda"
}

variable "network" {
  description = "Network configuration for nodes"
  type = object({
    cidr        = string
    gateway     = string
    dns_servers = list(string)
    vlan_id     = optional(number, null)
  })
}

variable "node" {
  description = "Proxmox node name for VM deployment"
  type        = string
}

variable "vm_base_id" {
  description = "The first VM ID for Proxmox VMs, with subsequent IDs counted up from it"
  type        = number
}

variable "worker" {
  description = "Specification of worker nodes"
  type = object({
    count = number
    specs = object({
      cpu    = number
      memory = number
      disk   = number
    })
  })
}
