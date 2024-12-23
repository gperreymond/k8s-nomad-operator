#/bin/bash

INTERFACE=$(ifconfig | grep -B1 "192.168.49" | awk '/^[a-z]/ {print $1}' | sed 's/://')
DATA_DIR=$PWD/opt/nomad

if [ -z "$INTERFACE" ]; then
  echo "[ERROR] no interface found for 192.168.49.x"
  exit 1
fi

cat <<EOF > nomad/client/dynamic.hcl
data_dir = "$DATA_DIR"
advertise {
  http = "{{ GetInterfaceIP \"$INTERFACE\" }}"
  rpc  = "{{ GetInterfaceIP \"$INTERFACE\" }}"
  serf = "{{ GetInterfaceIP \"$INTERFACE\" }}"
}
EOF

sudo .bin/nomad agent -node=nomad-local-client \
    -config=./nomad/client/default.hcl \
    -config=./nomad/client/paris.hcl \
    -config=./nomad/client/dynamic.hcl
