#/bin/bash

DATA_DIR=$PWD/opt/nomad-client
mkdir -p $DATA_DIR

cat <<EOF > nomad/client/dynamic.hcl
data_dir = "$DATA_DIR"
EOF

.bin/nomad agent -node=nomad-local-client \
    -config=./nomad/client/default.hcl \
    -config=./nomad/client/paris.hcl \
    -config=./nomad/client/dynamic.hcl
