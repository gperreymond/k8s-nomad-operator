data "kubernetes_resources" "nomad_namespaces" {
  api_version = "nomad.hashicorp.com/v1"
  kind        = "NomadNamespace"
  namespace   = var.kube_namespace
}

locals {
  namespaces = jsondecode(jsonencode(data.kubernetes_resources.nomad_namespaces.objects))
  processed_namespaces = [
    for namespace in local.namespaces : {
      capabilities = (
        namespace.spec.capabilities.disabled_task_drivers == null &&
        namespace.spec.capabilities.enabled_task_drivers == null
      ) ? null : namespace.spec.capabilities
      description = namespace.spec.description
      meta        = namespace.spec.meta
      name        = namespace.spec.name
      node_pool_config = (
        namespace.spec.node_pool_config.allowed == null &&
        namespace.spec.node_pool_config.default == null &&
        namespace.spec.node_pool_config.denied == null
      ) ? null : namespace.spec.node_pool_config
      provider = namespace.spec.provider
      quota    = namespace.spec.quota
    }
  ]
}

resource "nomad_namespace" "this" {
  for_each = { for namespace in local.processed_namespaces : namespace.name => namespace if namespace.provider == var.provider_name }

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
