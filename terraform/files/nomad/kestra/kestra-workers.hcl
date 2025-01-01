variable "kestra_docker_tag" {
  type = string
  default = "kestra-system"
}

variable "destination" {
  type = string
  default = "0.20.7"
}

job "kestra-workers" {
  region      = "europe"
  datacenters = ["paris"]
  namespace   = var.destination
  type        = "service"
  update {
    stagger      = "30s"
    max_parallel = 1
  }
  group "workers" {
    count = 2
    network {
      mode = "bridge"
      port "http" {
        to = 8080
      }
      port "management" {
        to = 8081
      }
    }
    service {
      name     = "kestra-worker-http"
      provider = "nomad"
      port     = "http"
    }
    service {
      name     = "kestra-worker-management"
      provider = "nomad"
      port     = "management"
    }
    task "worker" {
      driver = "docker"
      logs {
        max_files     = 1
        max_file_size = 5
      }
      config {
        image = "kestra/kestra:v${var.kestra_docker_tag}"
        args  = ["server", "worker"]
        ports = ["http", "management"]
        volumes = [
          "local/application.yml:/app/confs/application.yml:ro"
        ]
      }
      template {
        data        = <<EOH
JVM_ARGS="-Xms1024m -Xmx1024m"
MICRONAUT_CONFIG_FILES="/app/confs/application.yml"
EOH
        destination = "local/config.env"
        env         = true
      }
      template {
        data        = <<-EOF
{{ with nomadVar "kestra-external-configuration" }}{{ .application_kestra }}{{ end }}
EOF
        destination = "local/application.yml"
      }
      resources {
        cpu    = 250
        memory = 1024
      }
    }
  }
}
