#!/bin/bash

set -e

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VAGRANT_CONFIG=$PROJECT_ROOT/config_file.rb
CACHE_IMAGE_PATH=$PROJECT_ROOT/cached-images

source $PROJECT_ROOT/default-config
source $PROJECT_ROOT/$CLUSTER/setup.sh

NODE_BOX="centos/7"
MASTER_BOX="centos/7"
CACHE_FOUND=false

function clone-openshift-ansible {
  if [ ! -d "openshift-ansible" ] ; then
    echo "Cloning openshift-ansible..."
    git clone "https://github.com/ewolinetz/openshift-ansible.git"
    cd openshift-ansible
    echo "Checking out ewolinetz/service_catalog"
    git checkout origin/service_catalog
    cd ..
  else
    echo "openshift-ansible directory already found, skipping clone"
  fi
}

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

\$vm_memory = 16192
\$vm_vcpus = 2
\$vm_disk = 60
\$node_box = "${NODE_BOX}"
\$master_box = "${MASTER_BOX}"
\$subnet = "192.168.156"
EOF
}

declare -a CACHED_IMAGES=(
    "$CACHE_IMAGE_PATH/$VERSION"
)

function check-cached-images {
    for path in "${CACHED_IMAGES[@]}"; do
        version=$(echo $path | rev | cut -f 1 -d '/' | rev)
        if [[ -f "$path" ]] ; then source $path ; fi
        if [[ "${version}" == "${VERSION}" ]]; then
            echo "Found Cached Images"
            if [[ ${USE_CACHE} ]]; then
                echo "${version} -"
                echo "  MASTER:  ${master}"
                echo "  NODE:    ${node}"
                NODE_BOX=$node
                MASTER_BOX=$master
                CACHE_FOUND=true
                break
            fi
        fi
    done
}

check-cached-images
render-configfile
vagrant up --no-parallel
if [[ !$CACHE_FOUND ]]; then
    clone-openshift-ansible
    prepare-env
    start-cluster
    get-admin-creds
fi
