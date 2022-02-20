## Hashicorp Vault Stuff
variable "vault_token" {}

variable "proxmox_host_api_url" {
    default = "https://pve.random-domain.com/api2/json"
}

variable "template_name" {
    default = "debian-11-golden"
}

provider "vault" {
address = "https://hc-vault.random-domain.com/"
skip_tls_verify = false
token = "${var.vault_token}"
}

data "vault_generic_secret" "terraform-secrets" {
  path = "terraform-secrets/login"
}

# --
terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.3"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.proxmox_host_api_url
  pm_user = "${data.vault_generic_secret.terraform-secrets.data["ad_user"]}"
  pm_password = "${data.vault_generic_secret.terraform-secrets.data["ad_password"]}"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "nginx-nodes" {
  count = 3
  name = "nginx-${count.index}"
  target_node = "pve${count.index}"
  clone = var.template_name
  onboot = true
  full_clone = true
  agent = 1
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 512
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = "32G"
    type = "scsi"
    storage = "local-zfs"
    iothread = 1
  }
    #os_type = "cloud-init"

  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=10.10.10.10${count.index + 6}/24,gw=10.10.10.1"
}