locals {
  thanos_objstore_configuration = <<YAML
type: 's3'
config:
  bucket: 'thanos'
  endpoint: '${var.provider_minio_server}:${var.provider_minio_server_port}'
  access_key: '${minio_iam_service_account.thanos.access_key}'
  secret_key: '${minio_iam_service_account.thanos.secret_key}'
  insecure: true
YAML
}

// ----------------------------
// KUBERNETES
// ----------------------------

resource "kubernetes_secret" "thanos_sidecar_objstore_configuration" {
  metadata {
    name      = "thanos-objstore-config"
    namespace = kubernetes_namespace.monitoring.id
  }
  data = {
    "thanos.yaml" = local.thanos_objstore_configuration
  }

  depends_on = [
    null_resource.kestra,
  ]
}
resource "kubernetes_secret" "thanos_objstore_configuration" {
  metadata {
    name      = "thanos-objstore-config"
    namespace = kubernetes_namespace.thanos.id
  }
  data = {
    "thanos.yaml" = local.thanos_objstore_configuration
  }

  depends_on = [
    null_resource.kestra,
  ]
}

resource "null_resource" "monitoring" {
  depends_on = [
    null_resource.kestra,
    // kubernetes
    kubernetes_secret.thanos_sidecar_objstore_configuration,
    kubernetes_secret.thanos_objstore_configuration,
    // nomad
  ]
}
