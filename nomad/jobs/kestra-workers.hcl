job "kestra" {
  region      = "europe"
  datacenters = ["paris"]
  namespace   = "kestra-system"
  type        = "service"
  # Specify this job to have rolling updates, two-at-a-time, with
  # 30 second intervals.
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
        image = "kestra/kestra:v0.20.7"
        args  = ["server", "worker"]
        ports = ["http", "management"]
        volumes = [
          "local/application.yml:/app/confs/application.yml:ro"
        ]
      }
      template {
        data        = <<EOH
JVM_ARGS="-Xms1024m -Xmx1024m"
DATASOURCES_POSTGRES_PASSWORD="changeme"
DATASOURCES_POSTGRES_USERNAME="kestra"
MICRONAUT_CONFIG_FILES="/app/confs/application.yml"
EOH
        destination = "secrets/config.env"
        env         = true
      }
      template {
        data        = <<-EOF
datasources:
  postgres:
    driverClassName: org.postgresql.Driver
    url: jdbc:postgresql://192.168.49.60:5432/kestra
kestra:
  queue:
    type: postgres
  repository:
    type: postgres
  tutorialFlows:
    enabled: false
  storage:
    type: local
    local:
      basePath: "/app/storage"
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
