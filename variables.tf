# https://opentofu.org/docs/language/state/encryption/
variable "encryption_passphrase" {
  type        = string
  description = "The encryption passphrase for the Terraform state and plan"
}

variable "virtual_environment_endpoint" {
  type        = string
  description = "The endpoint for the Proxmox Virtual Environment API (example: https://host:port)"
}

variable "virtual_environment_password" {
  type        = string
  description = "The password for the Proxmox Virtual Environment API"
}

variable "virtual_environment_username" {
  type        = string
  description = "The username and realm for the Proxmox Virtual Environment API (example: root@pam)"
}

variable "proxmox_node_name" {
  type = string
  default = "proxmox"
  description = "value for the node_name attribute in the proxmox_virtual_environment_vm resource"
}

variable "proxmox_datastore_id" {
  type = string
  default = "local-lvm"
  description = "value for the datastore_id attribute in the proxmox_virtual_environment_* resources"
}

variable "cluster_node_network_gateway" {
  description = "The IP network gateway of the cluster nodes"
  type        = string
  default     = "10.0.0.254"
}

variable "cluster_node_network" {
  description = "The IP network prefix of the cluster nodes"
  type        = string
  default     = "10.0.0.0/24"
}

variable "cluster_node_network_first_controller_hostnum" {
  description = "The 4th octet of the ip of the first controller host"
  type        = number
  default     = 231
}

variable "cluster_node_network_first_worker_hostnum" {
  description = "The 4th octet of the ip of the first worker host"
  type        = number
  default     = 240
}

variable "controller_count" {
  type    = number
  default = 1
  validation {
    condition     = var.controller_count >= 1
    error_message = "Need at least one controller node."
  }
}

variable "worker_count" {
  type    = number
  default = 1
  validation {
    condition     = var.worker_count >= 1
    error_message = "Need at least one worker node."
  }
}

variable "prefix" {
  type    = string
  default = "talos"
}

variable "talos_version" {
  type = string
  default = "1.7.5"
  description = "value of the Talos version"
  validation {
    condition     = can(regex("^\\d+(\\.\\d+)+", var.talos_version))
    error_message = "Must be a valid version number."
  }
}

variable "kubernetes_version" {
  type = string
  default = "1.30.1"
  description = "value of the Kubernetes version"
  validation {
    condition     = can(regex("^\\d+(\\.\\d+)+", var.kubernetes_version))
    error_message = "Must be a valid version number."
  }
}

variable "talos_cluster_name" {
  description = "A name for the Talos cluster"
  type        = string
  default     = "talos-cluster"
}

variable "talos_cluster_vip" {
  description = "A virtual IP for the Talos cluster"
  type        = string
  default     = "10.0.0.230"
  validation {
    condition     = can(cidrnetmask("${var.talos_cluster_vip}/32"))
    error_message = "Must be a valid IPv4 address."
  }
}

variable "talos_cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
  type        = string
  default     = "https://talos.local:6443"
}
