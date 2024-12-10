provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "nomad" {
  address         = data.kubernetes_resource.nomad_provider.object.spec.address
  region          = data.kubernetes_resource.nomad_provider.object.spec.region
  http_auth       = data.kubernetes_resource.nomad_provider.object.spec.http_auth
  ca_file         = data.kubernetes_resource.nomad_provider.object.spec.ca_file
  ca_pem          = data.kubernetes_resource.nomad_provider.object.spec.ca_pem
  cert_file       = data.kubernetes_resource.nomad_provider.object.spec.cert_file
  cert_pem        = data.kubernetes_resource.nomad_provider.object.spec.cert_pem
  key_file        = data.kubernetes_resource.nomad_provider.object.spec.key_file
  key_pem         = data.kubernetes_resource.nomad_provider.object.spec.key_pem
  skip_verify     = data.kubernetes_resource.nomad_provider.object.spec.skip_verify
  vault_token     = data.kubernetes_resource.nomad_provider.object.spec.vault_token
  consul_token    = data.kubernetes_resource.nomad_provider.object.spec.consul_token
  secret_id       = data.kubernetes_resource.nomad_provider.object.spec.secret_id
  ignore_env_vars = data.kubernetes_resource.nomad_provider.object.spec.ignore_env_vars
}
