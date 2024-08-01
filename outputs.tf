output "controllers" {
  value = join(",", [for node in local.controller_nodes : node.address])
}

output "workers" {
  value = join(",", [for node in local.worker_nodes : node.address])
}

output "talos_cluster_endpoint" {
  value = var.talos_cluster_endpoint
}

output "talos_cluster_vip" {
  value = var.talos_cluster_vip
}

output "talosconfig" {
  value     = data.talos_client_configuration.talos.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.talos.kubeconfig_raw
  sensitive = true
}
