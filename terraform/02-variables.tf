data "kubernetes_resources" "nomad_variables" {
  api_version = "nomad.hashicorp.com/v1"
  kind        = "NomadVariable"
  namespace   = var.kube_namespace
}

locals {
  variables = jsondecode(jsonencode(data.kubernetes_resources.nomad_variables.objects))
  processed_variables = [
    for item in local.variables : {
      items     = item.spec.items
      namespace = item.spec.namespace
      path      = item.spec.path
      provider  = item.spec.provider
    }
  ]
}

resource "nomad_variable" "this" {
  for_each = { for item in local.processed_variables : item.path => item if item.provider == var.provider_name }

  namespace = each.value.namespace
  path      = each.value.path
  items     = each.value.items

  depends_on = [
    nomad_namespace.this,
  ]
}
