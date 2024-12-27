resource "minio_iam_user" "kestra" {
  name          = "kestra-system"
  force_destroy = true
  update_secret = true
}

resource "null_resource" "minio" {
  depends_on = [
    null_resource.keycloak,
    minio_iam_user.kestra,
  ]
}
