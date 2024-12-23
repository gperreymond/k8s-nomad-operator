data_dir = "/home/gperreymon/Workspaces/github/gperreymond/k8s-nomad-operator/opt/nomad"
advertise {
  http = "{{ GetInterfaceIP \"br-8a05419167c9\" }}"
  rpc  = "{{ GetInterfaceIP \"br-8a05419167c9\" }}"
  serf = "{{ GetInterfaceIP \"br-8a05419167c9\" }}"
}
