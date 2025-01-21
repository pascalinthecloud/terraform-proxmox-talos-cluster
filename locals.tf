# Define local variables for controlplane and worker nodes configuration
locals {
  # Extract nodes from controlplane overrides
  controlplane_nodes = [
    for _, override in var.controlplane.overrides : override.node
    if override.node != null
  ]

  # Extract nodes from worker overrides
  worker_nodes = [
    for _, override in var.worker.overrides : override.node
    if override.node != null
  ]

  # Combine and deduplicate all nodes 
  nodes = setunion(local.controlplane_nodes, local.worker_nodes, toset([var.node]))


  controlplanes = {
    for i in range(var.controlplane.count) : format("controlplane-%s", i + 1) => {
      hostname = format("%s-controlplane-%02d", var.cluster_name, i + 1)
      vm_id    = var.vm_base_id + i

      node = coalesce(
        try(var.controlplane.overrides[format("controlplane-%s", i + 1)].node, null),
        var.node
      )
      # Determine the IP address for the control plane node.
      # If an override is provided for the specific control plane node, use its IP address.
      # Otherwise, calculate the IP address based on the network CIDR and the node index.
      # The `coalesce` function returns the first non-null value from the provided arguments.
      # The `try` function attempts to extract the IP address from the override; if it fails, it returns null.
      # The `cidrhost` function calculates the IP address based on the network CIDR and the node index.b
      ip_address = coalesce(
        try(var.controlplane.overrides[format("controlplane-%s", i + 1)].network.ip_address, null),
        cidrhost(var.network.cidr, i + 10)
      )

      # Determine the subnet mask for the control plane node.
      # If an override is provided for the specific control plane node, use its CIDR to extract the subnet mask.
      # Otherwise, use the default network CIDR to extract the subnet mask.
      # The `coalesce` function returns the first non-null value from the provided arguments.
      # The `try` function attempts to split the override CIDR and extract the subnet mask; if it fails, it returns null.
      # The `split` function splits the CIDR string by the "/" delimiter and extracts the subnet mask (second element).
      subnet = coalesce(
        try(split("/", var.controlplane.overrides[format("controlplane-%s", i + 1)].network.cidr)[1], null),
        split("/", var.network.cidr)[1]
      )

      # Determine the CPU, memory, and disk specifications for the control plane node.
      # If an override is provided for the specific control plane node, use its specifications.
      # Otherwise, use the default specifications for the control plane nodes.
      # The `coalesce` function returns the first non-null value from the provided arguments.
      # The `try` function attempts to extract the specifications from the override; if it fails, it returns null.
      cpu = coalesce(
        try(var.controlplane.overrides[format("controlplane-%s", i + 1)].cpu, null),
        var.controlplane.specs.cpu
      )

      memory = coalesce(
        try(var.controlplane.overrides[format("controlplane-%s", i + 1)].memory, null),
        var.controlplane.specs.memory
      )

      disk = coalesce(
        try(var.controlplane.overrides[format("controlplane-%s", i + 1)].disk, null),
        var.controlplane.specs.disk
      )
    }
  }

  workers = {
    for i in range(var.worker.count) : format("worker-%s", i + 1) => {
      hostname = format("%s-worker-%02d", var.cluster_name, i + 1)
      vm_id    = var.vm_base_id + var.controlplane.count + i

      node = coalesce(
        try(var.worker.overrides[format("worker-%s", i + 1)].node, null),
        var.node
      )

      ip_address = coalesce(
        try(var.worker.overrides[format("worker-%s", i + 1)].network.ip_address, null),
        cidrhost(var.network.cidr, i + 10 + var.controlplane.count)
      )

      subnet = coalesce(
        try(split("/", var.worker.overrides[format("worker-%s", i + 1)].network.cidr)[1], null),
        split("/", var.network.cidr)[1]
      )

      cpu = coalesce(
        try(var.worker.overrides[format("worker-%s", i + 1)].cpu, null),
        var.worker.specs.cpu
      )

      memory = coalesce(
        try(var.worker.overrides[format("worker-%s", i + 1)].memory, null),
        var.worker.specs.memory
      )

      disk = coalesce(
        try(var.worker.overrides[format("worker-%s", i + 1)].disk, null),
        var.worker.specs.disk
      )
    }
  }
}
