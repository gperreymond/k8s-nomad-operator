output "namespaces" {
  value = { for namespace in local.processed_namespaces : namespace.name => namespace }
}
