terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.34.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "2.4.0"
    }
  }
}
