locals {
  controller_nodes = [
    for i in range(var.controller_count) : {
      name    = "controlplane-${i+1}"
      address = cidrhost(var.cluster_node_network, var.cluster_node_network_first_controller_hostnum + i)
    }
  ]
  worker_nodes = [
    for i in range(var.worker_count) : {
      name    = "worker-${i+1}"
      address = cidrhost(var.cluster_node_network, var.cluster_node_network_first_worker_hostnum + i)
    }
  ]

  common_machine_config = {
    machine = {
      features = {
        kubePrism = {
          enabled = true
          port    = 7445
        }
      }
    }
    cluster = {
      # see https://www.talos.dev/v1.7/talos-guides/discovery/
      # see https://www.talos.dev/v1.7/reference/configuration/#clusterdiscoveryconfig
      discovery = {
        enabled = true
        registries = {
          kubernetes = {
            disabled = true
          }
          service = {
            disabled = false
          }
        }
      }
    }
  }
}

#  https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_secrets
resource "talos_machine_secrets" "talos" {
  talos_version = "v${var.talos_version}"
}

#  https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration
data "talos_machine_configuration" "controller" {
  cluster_name       = var.talos_cluster_name
  cluster_endpoint   = var.talos_cluster_endpoint
  machine_secrets    = talos_machine_secrets.talos.machine_secrets
  machine_type       = "controlplane"
  talos_version      = "v${var.talos_version}"
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false
  config_patches = [
    yamlencode(local.common_machine_config),
    yamlencode({
      machine = {
        network = {
          interfaces = [
            # see https://www.talos.dev/v1.7/talos-guides/network/vip/
            {
              interface = "eth0"
              vip = {
                ip = var.talos_cluster_vip
              }
            }
          ]
        },
        features = {
          hostDNS = {
            enabled = true,
            forwardKubeDNSToHost = true,
            resolveMemberNames = true
          }
        }
      }
    }),
    yamlencode({
      cluster = {
        inlineManifests = [
          # {
          #   name = "metallb"
          #   contents = join("---\n", [
          #     data.helm_template.metallb.manifest,
          #     "# Source traefik.tf\n${local.metallb_config_manifest}",
          #   ])
          # },
          # {
          #   name = "traefik"
          #   contents = join("---\n", [
          #     data.helm_template.traefik.manifest,
          #     "# Source traefik.tf\n${local.traefik_config_manifest}",
          #   ])
          # },
          {
            name = "argocd"
            contents = join("---\n", [
              data.helm_template.argocd.manifest,
              "# Source argocd.tf\n${local.argocd_config_manifest}",
            ])
          },
        ],
      },
    })
  ]
}

#  https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration
data "talos_machine_configuration" "worker" {
  cluster_name       = var.talos_cluster_name
  cluster_endpoint   = var.talos_cluster_endpoint
  machine_secrets    = talos_machine_secrets.talos.machine_secrets
  machine_type       = "worker"
  talos_version      = "v${var.talos_version}"
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false
  config_patches = [
    yamlencode(local.common_machine_config),
    yamlencode({
      machine = {
        features = {
          hostDNS = {
            enabled = true,
            forwardKubeDNSToHost = true,
            resolveMemberNames = true
          }
        }
      }
    })
  ]
}

# https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/client_configuration
data "talos_client_configuration" "talos" {
  cluster_name         = var.talos_cluster_name
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoints            = [for node in local.controller_nodes : node.address]
}

# https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/cluster_kubeconfig
data "talos_cluster_kubeconfig" "talos" {
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoint             = local.controller_nodes[0].address
  node                 = local.controller_nodes[0].address
  depends_on = [
    talos_machine_bootstrap.talos,
  ]
}

# https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply
resource "talos_machine_configuration_apply" "controller" {
  count                       = var.controller_count
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controller.machine_configuration
  endpoint                    = local.controller_nodes[count.index].address
  node                        = local.controller_nodes[count.index].address
  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = "${var.prefix}-${local.controller_nodes[count.index].name}"
        }
      }
    }),
  ]
  depends_on = [
    proxmox_virtual_environment_vm.controller,
  ]
}

# https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply
resource "talos_machine_configuration_apply" "worker" {
  count                       = var.worker_count
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  endpoint                    = local.worker_nodes[count.index].address
  node                        = local.worker_nodes[count.index].address
  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = "${var.prefix}-${local.worker_nodes[count.index].name}"
        }
      }
    }),
  ]
  depends_on = [
    proxmox_virtual_environment_vm.worker,
  ]
}

# https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_bootstrap
resource "talos_machine_bootstrap" "talos" {
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoint             = local.controller_nodes[0].address
  node                 = local.controller_nodes[0].address
  depends_on = [
    talos_machine_configuration_apply.controller,
    talos_machine_configuration_apply.worker,
  ]
}
