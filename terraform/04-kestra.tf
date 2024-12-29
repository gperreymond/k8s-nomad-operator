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

// ----------------------------
// KUBERNETES
// ----------------------------

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

// ----------------------------
// NOMAD
// ----------------------------

resource "nomad_variable" "kestra_configuration" {
  path      = "kestra-external-configuration"
  namespace = nomad_namespace.kestra_system.id
  items = {
    application_kestra = local.kestra_configuration
  }

  depends_on = [
    null_resource.minio,
  ]
}
resource "nomad_job" "kestra_workers" {
  jobspec = file("${path.module}/files/nomad/kestra/kestra-workers.hcl")
  hcl2 {
    vars = {
      destination       = nomad_namespace.kestra_system.id,
      kestra_docker_tag = "0.20.7"
    }
  }

  depends_on = [
    nomad_variable.kestra_configuration,
  ]
}

resource "null_resource" "kestra" {
  depends_on = [
    null_resource.minio,
    // kubernetes
    kubernetes_secret.kestra_configuration,
    // nomad
    nomad_variable.kestra_configuration,
    nomad_job.kestra_workers,
  ]
}
