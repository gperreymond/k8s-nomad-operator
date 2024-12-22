#/bin/bash

INTERFACE=$(ifconfig | grep -B1 "192.168.49" | awk '/^[a-z]/ {print $1}' | sed 's/://')
DATA_DIR=$PWD/opt/nomad

if [ -z "$INTERFACE" ]; then
  echo "[ERROR] no interface found for 192.168.49.x"
  exit 1
fi

cat <<EOF > configs/nomad/client/dynamic.hcl
data_dir = "$DATA_DIR"
advertise {
  http = "{{ GetInterfaceIP \"$INTERFACE\" }}"
  rpc  = "{{ GetInterfaceIP \"$INTERFACE\" }}"
  serf = "{{ GetInterfaceIP \"$INTERFACE\" }}"
}
EOF

sudo .bin/nomad agent -node=nomad-local-client \
    -config=./configs/nomad/client/default.hcl \
    -config=./configs/nomad/client/paris.hcl \
    -config=./configs/nomad/client/dynamic.hcl
