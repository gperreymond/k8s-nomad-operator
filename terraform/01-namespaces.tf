// ----------------------------
// KUBERNETES
// ----------------------------

resource "kubernetes_namespace" "argo_system" {
  metadata {
    name = "argo-system"
  }
}
resource "kubernetes_namespace" "kestra_system" {
  metadata {
    name = "kestra-system"
  }
}
resource "kubernetes_namespace" "monitoring_system" {
  metadata {
    name = "monitoring-system"
  }
}
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}
resource "kubernetes_namespace" "thanos" {
  metadata {
    name = "thanos"
  }
}

// ----------------------------
// NOMAD
// ----------------------------

resource "nomad_namespace" "kestra_system" {
  name        = "kestra-system"
  description = "Dedicated to kestra runners."
}
resource "nomad_namespace" "monitoring_system" {
  name = "monitoring-system"
}

resource "null_resource" "namespaces" {
  depends_on = [
    // kubernetes
    kubernetes_namespace.argo_system,
    kubernetes_namespace.kestra_system,
    kubernetes_namespace.monitoring_system,
    kubernetes_namespace.monitoring,
    kubernetes_namespace.thanos,
    // nomad
    nomad_namespace.kestra_system,
    nomad_namespace.monitoring_system,
  ]
}
