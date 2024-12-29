// ----------------------------
// KESTRA
// ----------------------------

resource "minio_iam_user" "kestra" {
  name          = "kestra-system"
  force_destroy = true
  update_secret = true

  depends_on = [
    null_resource.keycloak
  ]
}
resource "minio_s3_bucket" "kestra" {
  bucket = "kestra"
  acl    = "private"

  depends_on = [
    null_resource.keycloak
  ]
}
resource "minio_iam_service_account" "kestra" {
  target_user = minio_iam_user.kestra.name
}
resource "minio_iam_policy" "kestra" {
  name   = "kestra-admin"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid":"KestraAdmin",
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Principal":"*",
      "Resource": ["${minio_s3_bucket.kestra.arn}", "${minio_s3_bucket.kestra.arn}/*"]
    }
  ]
}
EOF
}
resource "minio_iam_user_policy_attachment" "kestra" {
  user_name   = minio_iam_user.kestra.id
  policy_name = minio_iam_policy.kestra.name
}

// ----------------------------
// MONITORING
// ----------------------------

resource "minio_iam_user" "monitoring" {
  name          = "monitoring-system"
  force_destroy = true
  update_secret = true

  depends_on = [
    null_resource.keycloak
  ]
}
resource "minio_s3_bucket" "monitoring" {
  bucket = "monitoring"
  acl    = "private"

  depends_on = [
    null_resource.keycloak
  ]
}
resource "minio_iam_service_account" "monitoring" {
  target_user = minio_iam_user.monitoring.name
}
resource "minio_iam_policy" "monitoring" {
  name   = "monitoring-admin"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid":"MonitoringAdmin",
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Principal":"*",
      "Resource": ["${minio_s3_bucket.monitoring.arn}", "${minio_s3_bucket.monitoring.arn}/*"]
    }
  ]
}
EOF
}
resource "minio_iam_user_policy_attachment" "monitoring" {
  user_name   = minio_iam_user.monitoring.id
  policy_name = minio_iam_policy.monitoring.name
}


resource "null_resource" "minio" {
  depends_on = [
    null_resource.keycloak,
    // kestra
    minio_iam_user.kestra,
    minio_iam_service_account.kestra,
    minio_iam_user_policy_attachment.kestra,
    minio_iam_policy.kestra,
    minio_s3_bucket.kestra,
    // monitoring
    minio_iam_user.monitoring,
    minio_iam_service_account.monitoring,
    minio_iam_user_policy_attachment.monitoring,
    minio_iam_policy.monitoring,
    minio_s3_bucket.monitoring,
  ]
}
