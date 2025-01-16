# Define local variables for controlplane and worker nodes configuration
locals {
  controlplanes = {
    for i in range(var.controlplane.count) : format("%s-controlplane-%02d", var.cluster_name, i + 1) => {
      hostname   = format("controlplane-%s", i + 1)
      ip_address = cidrhost(var.network.cidr, i + 10)
      subnet     = split("/", var.network.cidr)[1]
      vm_id      = var.vm_base_id + i
      node_name  = var.node
      cpu        = var.controlplane.specs.cpu
      memory     = var.controlplane.specs.memory
      disk       = var.controlplane.specs.disk
    }
  }

  workers = {
    for i in range(var.worker.count) : format("%s-worker-%02d", var.cluster_name, i + 1) => {
      hostname   = format("worker-%s", i + 1)
      ip_address = cidrhost(var.network.cidr, i + 10 + var.controlplane.count)
      subnet     = split("/", var.network.cidr)[1]
      vm_id      = var.vm_base_id + var.controlplane.count + i
      node_name  = var.node
      cpu        = var.worker.specs.cpu
      memory     = var.worker.specs.memory
      disk       = var.worker.specs.disk
    }
  }
}
