#!/bin/bash

set -e

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VAGRANT_CONFIG=$PROJECT_ROOT/servers.yaml
CACHE_IMAGE_PATH=$PROJECT_ROOT/cached-images

source $PROJECT_ROOT/default-config
source $PROJECT_ROOT/$CLUSTER/setup.sh

declare -a CACHED_IMAGES=(
    "$CACHE_IMAGE_PATH/1.5.0-rc"
)

NODE_BOX="centos/7"
MASTER_BOX="centos/7"
CACHE_FOUND=false

function get-admin-creds {
    ./get-admin-creds.sh
}

function check-cached-images {
    for img_path in "${CACHED_IMAGES[@]}"; do
        version=$(echo $img_path | rev | cut -f 1 -d '/' | rev)
        source $img_path
        if [[ "${version}" == "${VERSION}" ]]; then
            echo "Found Cached Images"
            if $USE_CACHE; then
                echo "${version} -"
                cat $img_path
                CACHE_FOUND=true
                break
            fi
            echo "USE_CACHE is set to ${USE_CACHE}"
        fi
    done
}

function create-header {
cat << EOF | tee ${VAGRANT_CONFIG}
# servers.yaml
#
# THIS FILE IS MANAGED BY setup-cluster.sh #
---
EOF
}

function create-master-server {
if $CACHE_FOUND; then
    MASTER_BOX=$(cat $img_path | grep "master=" | cut -f 2 -d '=')
fi

cat << EOF | tee -a ${VAGRANT_CONFIG}
- name: master
  box: master-$version
  box_url: $MASTER_BOX
  ram: 1024
  vcpus: 1
  disk: 45
  ip: 192.168.156.2
EOF
}

function create-node-servers {
if $CACHE_FOUND; then
    NODE_BOX=$(cat $img_path | grep "node${1}=" | cut -f 2 -d '=')
fi

cat << EOF | tee -a ${VAGRANT_CONFIG}
- name: kube$1
  box: node$1-$version
  box_url: $NODE_BOX
  ram: 1024
  vcpus: 1
  disk: 45
  ip: 192.168.156.1$1
EOF
}

check-cached-images
create-header
for n in $(seq $NODE_COUNT); do
    create-node-servers $n
done
create-master-server
#vagrant up --no-parallel
if [[ !$CACHE_FOUND ]]; then
    prepare-env
    start-cluster
    get-admin-creds
fi
