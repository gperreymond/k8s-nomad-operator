locals {
  HELM_ARGO_CD_VERSION           = "7.7.11"
  HELM_STAKATER_RELOADER_VERSION = "1.2.0"
  HELM_KESTRA_VERSION            = "0.20.7"
}

resource "kubernetes_secret" "helm_oci_bitnamicharts" {
  metadata {
    name      = "helm-oci-bitnamicharts"
    namespace = kubernetes_namespace.argo_system.id
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    url = "registry-1.docker.io/bitnamicharts"
    name = "bitnamicharts"
    type = "helm"
    enableOCI = "true"
  }

  depends_on = [
    null_resource.monitoring,
  ]
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
    null_resource.monitoring,
  ]
}

resource "kubernetes_manifest" "argocd_projects" {
  for_each = { for filepath in fileset("${path.module}/files/argo-cd/projects", "*.yaml") : filepath => filepath }

  manifest = yamldecode(templatefile("${path.module}/files/argo-cd/projects/${each.key}", {
    argo_cd_namespace = kubernetes_namespace.argo_system.id
  }))

  depends_on = [
    helm_release.argo_cd,
  ]
}

resource "kubernetes_manifest" "argocd_applications" {
  for_each = { for filepath in fileset("${path.module}/files/argo-cd/applications", "*.yaml") : filepath => filepath }

  manifest = yamldecode(templatefile("${path.module}/files/argo-cd/applications/${each.key}", {
    argo_cd_namespace = kubernetes_namespace.argo_system.id
    kestra = {
      destination            = kubernetes_namespace.kestra_system.id
      chart_target_revision  = local.HELM_KESTRA_VERSION
      values_target_revision = "main"
    }
    stakater_reloader = {
      destination            = "kube-public"
      chart_target_revision  = local.HELM_STAKATER_RELOADER_VERSION
      values_target_revision = "main"
    }
    prometheus_operator = {
      destination         = kubernetes_namespace.monitoring_system.id
      git_target_revision = "main"
    }
    prometheus = {
      destination         = kubernetes_namespace.monitoring_system.id
      git_target_revision = "main"
    }
    alertmanager = {
      destination         = kubernetes_namespace.monitoring_system.id
      git_target_revision = "main"
    }
    # grafana = {
    #   destination         = kubernetes_namespace.monitoring_system.id
    #   git_target_revision = "main"
    # }
    thanos = {
      destination         = kubernetes_namespace.thanos_system.id
      git_target_revision = "main"
      memcached = {
        chart_target_revision = "7.6.1"
        values_target_revision = "main"
      }
    }
    kube_state_metrics = {
      destination         = kubernetes_namespace.monitoring_system.id
      git_target_revision = "main"
    }
    node_exporter = {
      destination         = kubernetes_namespace.monitoring_system.id
      git_target_revision = "main"
    }
    kubernetes = {
      destination         = kubernetes_namespace.monitoring_system.id
      git_target_revision = "main"
    }
  }))

  depends_on = [
    kubernetes_manifest.argocd_projects,
  ]
}

resource "null_resource" "argo" {
  depends_on = [
    null_resource.monitoring,
    helm_release.argo_cd,
    kubernetes_manifest.argocd_projects,
    kubernetes_manifest.argocd_applications,
  ]
}
