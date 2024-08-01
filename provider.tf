# Proxmox Provider
# ---
# Initial Provider Configuration for Proxmox

terraform {

  # tofu 1.7.0 for state/plan encryption
  required_version = ">= 1.7.0"

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.4"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.60.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.virtual_environment_endpoint
  username = var.virtual_environment_username
  password = var.virtual_environment_password
  insecure = true
  ssh {
    agent = true
  }
}
