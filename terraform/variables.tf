variable "provider_keycloak_username" {
  type    = string
  default = "admin"
}

variable "provider_keycloak_password" {
  type    = string
  default = "changeme"
}

variable "provider_minio_server" {
  type    = string
  default = "192.168.49.49"
}

variable "provider_minio_server_port" {
  type    = string
  default = "9000"
}

variable "provider_minio_username" {
  type    = string
  default = "admin"
}

variable "provider_minio_password" {
  type    = string
  default = "changeme"
}

variable "kestra_postgres_username" {
  type    = string
  default = "kestra"
}

variable "kestra_postgres_password" {
  type    = string
  default = "changeme"
}
