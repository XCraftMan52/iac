variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token, format: user@realm!tokenid=uuid"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name to deploy VMs on"
  type        = string
  default     = "adams"
}

variable "proxmox_storage" {
  description = "Proxmox storage id for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "proxmox_bridge" {
  description = "Proxmox network bridge for VM NICs"
  type        = string
  default     = "vmbr0"
}

variable "talos_version" {
  description = "Talos Linux version to install"
  type        = string
  default     = "v1.13.7"
}

variable "talos_iso_url" {
  description = "URL to the Talos metal ISO (build via https://factory.talos.dev if you need custom system extensions, e.g. qemu-guest-agent)"
  type        = string
  default     = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.13.7/metal-amd64.iso"
}

variable "nodes" {
  description = "Map of the 3 Talos nodes: name => config"
  type = map(object({
    vm_id     = number
    ip        = string
    cores     = number
    memory_mb = number
    disk_gb   = number
  }))
  default = {
    "k8s-home-01" = {
      vm_id     = 111
      ip        = "10.32.100.21"
      cores     = 4
      memory_mb = 8192
      disk_gb   = 280
    }
    "k8s-home-02" = {
      vm_id     = 112
      ip        = "10.32.100.22"
      cores     = 4
      memory_mb = 8192
      disk_gb   = 280
    }
    "k8s-home-03" = {
      vm_id     = 113
      ip        = "10.32.100.23"
      cores     = 4
      memory_mb = 8192
      disk_gb   = 280
    }
  }
}
