data_dir = "/opt/nomad"
log_level  = "INFO"
log_json  = true
leave_on_interrupt = true
leave_on_terminate = true
client {
  enabled = true
  server_join {
    retry_join     = [ "nomad-europe-paris-1", "nomad-europe-paris-2" ]
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
    allow_caps = ["all"]
    volumes {
      enabled = true
    }
  }
}
advertise {
  http = "{{ GetInterfaceIP \"eth0\" }}"
  rpc  = "{{ GetInterfaceIP \"eth0\" }}"
  serf = "{{ GetInterfaceIP \"eth0\" }}"
}
bind_addr = "0.0.0.0"