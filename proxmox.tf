# see https://registry.terraform.io/providers/bpg/proxmox/0.57.1/docs/resources/virtual_environment_file
resource "proxmox_virtual_environment_file" "talos" {
  datastore_id = "local"
  node_name    = var.proxmox_node_name
  content_type = "iso"
  source_file {
    path      = "talos/_out/talos-nocloud.qcow2"
    file_name = "talos-nocloud.img"
  }
}

# see https://registry.terraform.io/providers/bpg/proxmox/0.57.1/docs/resources/virtual_environment_vm
resource "proxmox_virtual_environment_vm" "controller" {
  count           = var.controller_count
  name            = "${var.prefix}-${local.controller_nodes[count.index].name}"
  node_name       = var.proxmox_node_name
  tags            = sort(["talos", "controller", "kubernetes", "opentofu", "cloud-init"])
  stop_on_destroy = true
  bios            = "ovmf"
  machine         = "q35"
  scsi_hardware   = "virtio-scsi-single"
  operating_system {
    type = "l26"
  }
  cpu {
    type  = "host"
    cores = 4
  }
  memory {
    dedicated = 4 * 1024
  }
  vga {
    type = "qxl"
  }
  network_device {
    bridge = "vmbr0"
  }
  tpm_state {
    version = "v2.0"
  }
  efi_disk {
    datastore_id = var.proxmox_datastore_id
    file_format  = "raw"
    type         = "4m"
  }
  disk {
    datastore_id = var.proxmox_datastore_id
    interface    = "scsi0"
    iothread     = true
    ssd          = true
    discard      = "on"
    size         = 40
    file_format  = "raw"
    file_id      = proxmox_virtual_environment_file.talos.id
  }
  agent {
    enabled = true
    trim    = true
  }
  initialization {
    ip_config {
      ipv4 {
        address = "${local.controller_nodes[count.index].address}/24"
        gateway = var.cluster_node_network_gateway
      }
    }
  }
  depends_on = [
    proxmox_virtual_environment_file.talos,
  ]
}

# see https://registry.terraform.io/providers/bpg/proxmox/0.57.1/docs/resources/virtual_environment_vm
resource "proxmox_virtual_environment_vm" "worker" {
  count           = var.worker_count
  name            = "${var.prefix}-${local.worker_nodes[count.index].name}"
  node_name       = var.proxmox_node_name
  tags            = sort(["talos", "worker", "kubernetes", "opentofu", "cloud-init"])
  stop_on_destroy = true
  bios            = "ovmf"
  machine         = "q35"
  scsi_hardware   = "virtio-scsi-single"
  operating_system {
    type = "l26"
  }
  cpu {
    type  = "host"
    cores = 4
  }
  memory {
    dedicated = 2 * 1024
  }
  vga {
    type = "qxl"
  }
  network_device {
    bridge = "vmbr0"
  }
  tpm_state {
    version = "v2.0"
  }
  efi_disk {
    datastore_id = var.proxmox_datastore_id
    file_format  = "raw"
    type         = "4m"
  }
  disk {
    datastore_id = var.proxmox_datastore_id
    interface    = "scsi0"
    iothread     = true
    ssd          = true
    discard      = "on"
    size         = 40
    file_format  = "raw"
    file_id      = proxmox_virtual_environment_file.talos.id
  }
  disk {
    datastore_id = var.proxmox_datastore_id
    interface    = "scsi1"
    iothread     = true
    ssd          = true
    discard      = "on"
    size         = 60
    file_format  = "raw"
  }
  agent {
    enabled = true
    trim    = true
  }
  initialization {
    ip_config {
      ipv4 {
        address = "${local.worker_nodes[count.index].address}/24"
        gateway = var.cluster_node_network_gateway
      }
    }
  }
  depends_on = [
    proxmox_virtual_environment_file.talos,
  ]
}
