log_level          = "INFO"
log_json           = true
leave_on_interrupt = true
leave_on_terminate = true
client {
  enabled = true
  server_join {
    retry_join     = ["192.168.49.21", "192.168.49.22", "192.168.49.23"]
    retry_max      = 3
    retry_interval = "15s"
  }
}
plugin "raw_exec" {
  config {
    enabled = true
  }
}
plugin "docker" {
  config {
    allow_privileged = true
    allow_caps       = ["all"]
    volumes {
      enabled = true
    }
  }
}
advertise {
  http = "192.168.49.200"
  rpc  = "192.168.49.200"
  serf = "192.168.49.200"
}
bind_addr = "0.0.0.0"
