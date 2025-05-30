resource "proxmox_virtual_environment_vm" "worker" {
  for_each = local.workers

  node_name = each.value.node
  name      = each.key
  description = templatefile("${path.module}/templates/description.tftpl", {
    cluster_name = var.cluster.name,
    node_name    = each.key
    subnet       = "${each.value.ip_address}/${each.value.subnet}"
    gateway      = var.network.gateway
    cpu          = each.value.cpu
    memory       = each.value.memory
    disk         = each.value.disk
    proxmox_node = each.value.node
  })
  tags = [var.cluster.name]
  vm_id         = each.value.vm_id
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "seabios"

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cpu
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  network_device {
    bridge  = var.network.bridge
    vlan_id = var.network.vlan_id
  }

  disk {
    datastore_id = each.value.datastore
    interface    = "scsi0"
    iothread     = true
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    file_format  = "raw"
    size         = each.value.disk
    file_id      = proxmox_virtual_environment_download_file.this[each.value.node].id
  }

  boot_order = ["scsi0"]

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 6.X.
  }

  initialization {
    datastore_id = each.value.datastore

    dns {
      servers = var.network.dns_servers
    }

    ip_config {
      ipv4 {
        address = "${each.value.ip_address}/${each.value.subnet}"
        gateway = var.network.gateway
      }
    }
  }
}
