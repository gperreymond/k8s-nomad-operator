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


resource "null_resource" "minio" {
  depends_on = [
    null_resource.keycloak,
    minio_iam_user.kestra,
    minio_iam_service_account.kestra,
    minio_iam_user_policy_attachment.kestra,
    minio_iam_policy.kestra,
    minio_s3_bucket.kestra
  ]
}
