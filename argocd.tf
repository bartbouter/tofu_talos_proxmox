locals {
  argocd_config_manifests = [
    {
      apiVersion = "v1"
      kind       = "Namespace"
      metadata = {
        name = "argocd"
      }
    }
  ]
  argocd_config_manifest = join("---\n", [for t in local.argocd_config_manifests : yamlencode(t)])
}

data "helm_template" "argocd" {
  namespace    = "argocd"
  name         = "argocd"
  repository   = "https://argoproj.github.io/argo-helm"
  chart        = "argo-cd"
  kube_version = var.kubernetes_version
  include_crds = true
  set {
    name = "global.domain"
    value = "argocd.local"
  }
}
