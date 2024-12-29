resource "null_resource" "monitoring" {
  depends_on = [
    null_resource.kestra,
    // kubernetes
    // nomad
  ]
}
