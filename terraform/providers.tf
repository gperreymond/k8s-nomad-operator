provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}

provider "keycloak" {
  url       = "http://keycloak.docker.localhost"
  client_id = "admin-cli"
  username  = var.provider_keycloak_username
  password  = var.provider_keycloak_password
}

provider "minio" {
  minio_server   = "${var.provider_minio_server}:${var.provider_minio_server_port}"
  minio_user     = var.provider_minio_username
  minio_password = var.provider_minio_password
}

provider "nomad" {
  address = "http://nomad.europe-paris.docker.localhost"
  region  = "europe"
}
