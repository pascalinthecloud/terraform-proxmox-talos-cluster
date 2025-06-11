---
title: Setup provider configuration
description: This guide provides instructions on how to configure the provider 
---

# 1. Create API Token
You can create an API Token for a user via the Proxmox UI, or via the command line on the Proxmox host or cluster:

- Create a user:

    ```sh
    sudo pveum user add terraform@pve
    ```

- Create a role for the user (you can skip this step if you want to use any of the existing roles):

    ```sh
    sudo pveum role add Terraform -privs "Mapping.Audit Mapping.Modify Mapping.Use Permissions.Modify Pool.Allocate Pool.Audit Realm.AllocateUser Realm.Allocate SDN.Allocate SDN.Audit Sys.Audit Sys.Console Sys.Incoming Sys.Modify Sys.AccessNetwork Sys.PowerMgmt Sys.Syslog User.Modify Group.Allocate SDN.Use VM.Allocate VM.Audit VM.Backup VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Console VM.Migrate VM.Monitor VM.PowerMgmt VM.Snapshot.Rollback VM.Snapshot Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit"
    ```

  ~> The list of privileges above is only an example, please review it and adjust to your needs.
  Refer to the [privileges documentation](https://pve.proxmox.com/pve-docs/pveum.1.html#_privileges) for more details.

- Assign the role to the previously created user:

    ```sh
    sudo pveum aclmod / -user terraform@pve -role Terraform
    ```

- Create an API token for the user:

    ```sh
    sudo pveum user token add terraform@pve provider --privsep=0
    ```
<br>

# 2. Configure SSH on Proxmox Node
Since we’re using a custom image, a working SSH connection to the Proxmox node is required for the proxmox_virtual_environment_file Terraform resource.

🚫 Don't use the root user — instead, let’s create a dedicated user for this first. 👤✅


-> `sudo` may not be installed by default on Proxmox VE nodes. You can install it via the command line on the Proxmox host: `apt install sudo`


You can configure the `sudo` privilege for the user via the command line on the Proxmox host.
In the example below, we create a user `terraform` and assign the `sudo` privilege to it. Run the following commands on each Proxmox node in the root shell:

- Create a new system user:

    ```sh
    useradd -m terraform
    ```
    

- Configure the `sudo` privilege for the user, by adding a new sudoers file to the `/etc/sudoers.d` directory:

    ```sh
    visudo -f /etc/sudoers.d/terraform
    ```

  Add the following lines to the file:

    ```text
    terraform ALL=(root) NOPASSWD: /sbin/pvesm
    terraform ALL=(root) NOPASSWD: /sbin/qm
    terraform ALL=(root) NOPASSWD: /usr/bin/tee /var/lib/vz/*
    ```

  If you're using a different datastore for snippets, not the default `local`, you should add the datastore's mount point to the sudoers file as well, for example:
  
    ```text
    terraform ALL=(root) NOPASSWD: /usr/bin/tee /mnt/pve/cephfs/*
    ```

  You can find the mount point of the datastore by running `pvesh get /storage/<name>` on the Proxmox node.
<br>

- Copy your SSH public key to the `~/.ssh/authorized_keys` file of the `terraform` user on the target node.
    <br>

- Test the SSH connection and password-less `sudo`:
  
    ```sh
    ssh terraform@<target-node> sudo pvesm apiinfo 
    ```

  You should be able to connect to the target node and see the output containing `APIVER <number>` on the scr


- Before saving private key in secret store, you should replace linebreaks with \n 
  ```sh
      cat proxmox_homelab | awk '{printf "%s\\n", $0}'
  ```
<br>

# 3. Configure the providers.tf part in Terraform

```terraform
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.69.0, < 1.0.0"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://your-proxmox-host.dev/api2/json"
  api_token = var.proxmox_api_key
  ssh {
    agent    = true
    username = "terraform"
    private_key = var.terraform_proxmox_private_key

  }
}
```

🚀 You're all set!
You should now be able to deploy a cluster using the module. ✅