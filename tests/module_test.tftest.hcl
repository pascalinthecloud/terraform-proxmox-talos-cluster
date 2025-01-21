mock_provider "proxmox" {
}


run "verify" {
    variables {
        vm_base_id   = 800
        cluster_name = "homelab.cluster"
        datastore    = "local-lvm"
        node         = "pve03"

        image = {
            version    = "v1.9.1"
            extensions = ["qemu-guest-agent", "iscsi-tools", "util-linux-tools"]
        }

        network = {
            cidr        = "10.10.101.0/24"
            gateway     = "10.10.101.1"
            dns_servers = ["10.0.10.1", "1.1.1.1"]
            vlan_id     = 1101
        }

        controlplane = {
            count = 1
            specs = {
            cpu    = 2
            memory = 4096
            disk   = 30
            }
        }

        worker = {
            count = 2
            specs = {
            cpu    = 2
            memory = 6192
            disk   = 30
            }
        }
    }
    providers = {
      proxmox = proxmox
    }
    module {
        source = "./"
    }
   command = plan
    assert {
      condition = contains(keys(proxmox_virtual_environment_vm.controlplane),"homelab.cluster-controlplane-01")
      error_message = "lul"
    }
    assert {
      condition = local.controlplanes["homelab.cluster-controlplane-01"].ip_address == "10.10.101.10"
      error_message = "lul"
    }
}