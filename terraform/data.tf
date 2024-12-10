data "kubernetes_resource" "nomad_provider" {
  api_version = "nomad.hashicorp.com/v1"
  kind        = "NomadProvider"
  metadata {
    name      = var.provider_name
    namespace = var.kube_namespace
  }
}
