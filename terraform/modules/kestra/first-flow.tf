resource "kestra_flow" "hello" {
  namespace = "testing.team"
  flow_id   = "hello"
  content   = <<EOT
tasks:
  - id: hello
    type: io.kestra.plugin.core.log.Log
    message: Hello World! 🚀
EOT
}
