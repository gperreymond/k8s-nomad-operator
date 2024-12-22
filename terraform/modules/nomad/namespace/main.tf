variable "namespace" {
  type = string
}
resource "nomad_namespace" "this" {
  name = var.namespace
}
output "namespace" {
  value     = nomad_namespace.this.name
  sensitive = false
}