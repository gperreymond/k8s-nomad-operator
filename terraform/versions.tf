terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.2.2"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}
