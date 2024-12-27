locals {
  kestra_configuration = <<YAML
datasources:
  postgres:
    url: 'jdbc:postgresql://192.168.49.60:5432/kestra'
    driverClassName: org.postgresql.Driver
    username: '${var.kestra_postgres_username}'
    password: '${var.kestra_postgres_password}'
kestra:
  tutorialFlows:
    enabled: false
  queue:
    type: 'postgres'
  repository:
    type: 'postgres'
  storage:
    type: 'minio'
    minio:
      endpoint: '${var.provider_minio_server}'
      port: '${var.provider_minio_server_port}'
      access-key: '${minio_iam_service_account.kestra.access_key}'
      secret-key: '${minio_iam_service_account.kestra.secret_key}'
      secure: 'false'
      bucket: 'kestra'
YAML
}

resource "kubernetes_secret" "kestra_configuration" {
  metadata {
    name      = "kestra-external-configuration"
    namespace = kubernetes_namespace.kestra_system.id
  }
  data = {
    "application-kestra.yml" = local.kestra_configuration
  }

  depends_on = [
    null_resource.minio,
  ]
}

resource "nomad_variable" "kestra_configuration" {
  path      = "kestra-external-configuration"
  namespace = nomad_namespace.kestra_system.id
  items = {
    "application-kestra.yml" = local.kestra_configuration
  }

  depends_on = [
    null_resource.minio,
  ]
}


resource "null_resource" "kestra" {
  depends_on = [
    null_resource.minio,
    kubernetes_secret.kestra_configuration,
    nomad_variable.kestra_configuration,
  ]
}
