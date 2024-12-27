locals {
  HELM_ARGO_CD_VERSION = "7.7.11"
}

resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  repository = "oci://ghcr.io/argoproj/argo-helm"
  chart      = "argo-cd"
  version    = local.HELM_ARGO_CD_VERSION

  namespace = kubernetes_namespace.argo_system.id
  values = [
    "${file("files/helm-values/argo-cd.yaml")}", <<YAML
clusterCredentials: []
YAML
  ]

  depends_on = [
    null_resource.namespaces,
  ]
}

resource "kubernetes_manifest" "argocd_projects" {
  for_each = { for filepath in fileset("./files/argo-cd/projects", "*.yaml") : filepath => filepath }

  manifest = yamldecode(templatefile("./files/argo-cd/projects/${each.key}", {
    argo_cd_namespace = kubernetes_namespace.argo_system.id
  }))

  depends_on = [
    helm_release.argo_cd,
  ]
}

resource "kubernetes_manifest" "argocd_applications" {
  for_each = { for filepath in fileset("./files/argo-cd/applications", "*.yaml") : filepath => filepath }

  manifest = yamldecode(templatefile("./files/argo-cd/applications/${each.key}", {
    argo_cd_namespace = kubernetes_namespace.argo_system.id
    stakater_reloader = {
      destination            = "kube-public"
      chart_target_revision  = "1.2.0"
      values_target_revision = "main"
    }
  }))

  depends_on = [
    kubernetes_manifest.argocd_projects,
  ]
}

resource "null_resource" "argo" {
  depends_on = [
    helm_release.argo_cd,
    kubernetes_manifest.argocd_projects,
    kubernetes_manifest.argocd_applications,
  ]
}
