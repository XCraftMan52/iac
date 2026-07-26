terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = false
}

resource "proxmox_download_file" "talos_iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = var.talos_iso_url
  file_name    = "talos-${var.talos_version}-amd64.iso"
}

resource "proxmox_virtual_environment_vm" "talos" {
  for_each = var.nodes

  name      = each.key
  node_name = var.proxmox_node
  vm_id     = each.value.vm_id

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory_mb
  }

  agent {
    enabled = true
  }

  cdrom {
    file_id = proxmox_download_file.talos_iso.id
  }

  disk {
    datastore_id = var.proxmox_storage
    interface    = "scsi0"
    size         = each.value.disk_gb
    ssd          = true
  }

  network_device {
    bridge = var.proxmox_bridge
  }

  operating_system {
    type = "l26"
  }

  # Talos boots from ISO; static IP + hostname are applied later via talhelper/talosctl
  boot_order = ["scsi0", "ide3"]

  lifecycle {
    ignore_changes = [cdrom] # detach ISO after first Talos install without forcing a rebuild
  }
}

output "node_ips" {
  value = { for k, v in var.nodes : k => v.ip }
}
