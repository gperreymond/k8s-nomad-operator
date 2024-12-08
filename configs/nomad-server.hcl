datacenter = "europe-paris"
data_dir = "/opt/nomad"
log_level  = "INFO"
log_json  = true
leave_on_interrupt = false
leave_on_terminate = true
autopilot {
  cleanup_dead_servers = true
}
server {
  enabled = true
  bootstrap_expect = 1
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
