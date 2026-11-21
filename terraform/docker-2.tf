# docker-2: GPU VM for Ollama + Immich ML. Isolated from docker-1 so a GPU
# fault can't take the rest of the Docker stack down with it.
#
# Host prerequisites (done by hand on adams, not managed here):
#   - BIOS: Re-Size BAR off, Above 4G Decoding on, IOMMU on
#   - RX 7600 (03:00.0 1002:7480, 03:00.1 1002:ab30) bound to vfio-pci via
#     /etc/modprobe.d/vfio.conf
#   - Datacenter > Resource Mappings > PCI: "rx7600" -> 0000:03:00 (needed
#     because raw PCI IDs can only be passed through by root@pam, not a token)

# "import" content type lets the VM's disk be created over the API alone; an
# "iso"-type image makes the provider SSH into the node as root instead.
resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://cloud-images.ubuntu.com/releases/26.04/release/ubuntu-26.04-server-cloudimg-amd64.img"
  file_name    = "ubuntu-26.04-server-cloudimg-amd64.qcow2" # the .img is qcow2
}

resource "proxmox_virtual_environment_vm" "docker_2" {
  name      = "docker-2"
  node_name = var.proxmox_node
  vm_id     = 102

  # q35 + OVMF: PCIe passthrough of a modern GPU doesn't work on i440fx/SeaBIOS
  machine = "q35"
  bios    = "ovmf"

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 16384 # no ballooning: passthrough pins all guest RAM anyway
  }

  # Cloud image has no qemu-guest-agent; enabling this before it's installed
  # makes the provider wait for the agent until it times out.
  agent {
    enabled = false
  }

  efi_disk {
    datastore_id      = var.proxmox_storage
    type              = "4m"
    pre_enrolled_keys = false # Secure Boot off
  }

  disk {
    datastore_id = var.proxmox_storage
    import_from  = proxmox_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 150 # Ollama models are large
    ssd          = true
    discard      = "on"
  }

  hostpci {
    device  = "hostpci0"
    mapping = "rx7600"
    pcie    = true
  }

  network_device {
    bridge = var.proxmox_bridge
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.proxmox_storage

    ip_config {
      ipv4 {
        address = "10.32.100.43/24"
        gateway = "10.32.100.1"
      }
    }

    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }

    user_account {
      username = "xcraftman52"
      keys     = [trimspace(file(pathexpand("~/.ssh/docker-2.pub")))]
    }
  }

  lifecycle {
    ignore_changes = [disk[0].import_from] # a newer cloud image must not rebuild the VM
  }
}
