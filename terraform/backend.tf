terraform {
  backend "kubernetes" {
    namespace      = "nomad-system"
    secret_suffix  = "state"
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}
