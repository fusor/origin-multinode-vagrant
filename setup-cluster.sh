#!/bin/bash

set -e

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VAGRANT_CONFIG=$PROJECT_ROOT/config_file.rb

source $PROJECT_ROOT/default-config
source $PROJECT_ROOT/$CLUSTER/setup.sh

function get-admin-creds {
    ./get-admin-creds.sh
}

function render-configfile {
    NODE_COUNT=$((VM_COUNT-1))

cat << EOF | tee ${VAGRANT_CONFIG}
# THIS FILE IS MANAGED BY setup-cluster.sh #
# Cluster info
\$node_count = ${NODE_COUNT}
\$master_count = 1

\$vm_memory = 1024
\$vm_vcpus = 1
\$vm_disk = 45
\$node_box = "centos/7"
\$master_box = "centos/7"
\$subnet = "192.168.156"
EOF
}

render-configfile
vagrant up --no-parallel
prepare-env
start-cluster
get-admin-creds
