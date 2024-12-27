resource "kubernetes_secret" "kestra_configuration" {
  metadata {
    name      = "kestra-external-configuration"
    namespace = kubernetes_namespace.kestra_system.id
  }
  data = {
    "application-kestra.yml" = <<YAML
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
      access-key: '${minio_iam_user.kestra.id}'
      secret-key: '${minio_iam_user.kestra.secret}'
      secure: 'false'
      bucket: 'kestra'
YAML
  }

  depends_on = [
    null_resource.minio,
  ]
}

resource "null_resource" "kestra" {
  depends_on = [
    null_resource.minio,
    kubernetes_secret.kestra_configuration,
  ]
}
