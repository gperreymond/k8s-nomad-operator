output "namespaces" {
  value = [for item in local.processed_namespaces : item.name]
}

output "variables" {
  value = [for item in local.processed_variables : "${item.namespace}:${item.path}"]
}
