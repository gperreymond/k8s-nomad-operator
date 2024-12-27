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

resource "nomad_namespace" "kestra_system" {
  name        = "kestra-system"
  description = "Dedicated to kestra runners."
}

resource "null_resource" "namespaces" {
  depends_on = [
    kubernetes_namespace.argo_system,
    kubernetes_namespace.kestra_system,
    nomad_namespace.kestra_system,
  ]
}
