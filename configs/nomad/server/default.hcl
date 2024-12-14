data_dir = "/opt/nomad"
log_level  = "INFO"
log_json  = true
leave_on_interrupt = true
leave_on_terminate = true
disable_update_check = true
autopilot {
  cleanup_dead_servers = true
}
server {
  enabled = true
  bootstrap_expect = 3
  server_join {
    retry_join     = [
      "nomad-europe-paris-1",
      "nomad-europe-paris-2",
      "nomad-europe-paris-3"
    ]
    retry_max      = 3
    retry_interval = "15s"
  }
}
client {
  enabled = false
}
advertise {
  http = "{{ GetInterfaceIP \"eth0\" }}"
  rpc  = "{{ GetInterfaceIP \"eth0\" }}"
  serf = "{{ GetInterfaceIP \"eth0\" }}"
}
bind_addr = "0.0.0.0"
