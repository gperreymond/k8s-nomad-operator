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

resource "null_resource" "namespaces" {
  depends_on = [
    kubernetes_namespace.argo_system,
    kubernetes_namespace.kestra_system,
  ]
}
