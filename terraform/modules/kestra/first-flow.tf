resource "kestra_flow" "hello" {
  flow_id   = "hello"
  namespace = "testing.team"
  content   = <<EOT
id: hello
namespace: testing.team
tasks:
  - id: log-hello-world
    type: io.kestra.plugin.core.log.Log
    message: Hello World! 🚀
EOT
}
