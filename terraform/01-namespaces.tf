data "kubernetes_resources" "nomad_namespaces" {
  api_version = "nomad.hashicorp.com/v1"
  kind        = "NomadNamespace"
  namespace   = var.kube_namespace
}

locals {
  namespaces = jsondecode(jsonencode(data.kubernetes_resources.nomad_namespaces.objects))
  processed_namespaces = [
    for item in local.namespaces : {
      capabilities = (
        item.spec.capabilities.disabled_task_drivers == null &&
        item.spec.capabilities.enabled_task_drivers == null
      ) ? null : item.spec.capabilities
      description = item.spec.description
      meta        = item.spec.meta
      name        = item.spec.name
      node_pool_config = (
        item.spec.node_pool_config.allowed == null &&
        item.spec.node_pool_config.default == null &&
        item.spec.node_pool_config.denied == null
      ) ? null : item.spec.node_pool_config
      provider = item.spec.provider
      quota    = item.spec.quota
    }
  ]
}

resource "nomad_namespace" "this" {
  for_each = { for item in local.processed_namespaces : item.name => item if item.provider == var.provider_name }

  name        = each.key
  description = each.value.description
  quota       = each.value.quota
  meta        = each.value.meta

  dynamic "capabilities" {
    for_each = each.value.capabilities != null ? [each.value.capabilities] : []
    content {
      enabled_task_drivers  = capabilities.value.enabled_task_drivers
      disabled_task_drivers = capabilities.value.disabled_task_drivers
    }
  }

  dynamic "node_pool_config" {
    for_each = each.value.node_pool_config != null ? [each.value.node_pool_config] : []
    content {
      default = node_pool_config.value.default
      allowed = node_pool_config.value.allowed
      denied  = node_pool_config.value.denied
    }
  }
}
