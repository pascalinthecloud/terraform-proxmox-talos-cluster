terraform {
  required_version = ">= 1.9.2"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.69.0, < 1.0.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.7.0, < 1.0.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.0, < 4.0.0"
    }
  }
}
