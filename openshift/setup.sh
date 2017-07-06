#!/bin/bash

ANSIBLE_HOSTS="/etc/ansible/hosts"
# Playbook:
# https://github.com/openshift/openshift-ansible
OPENSHIFT_ANSIBLE_DIR="${OPENSHIFT_ANSIBLE_DIR:-${PROJECT_ROOT}/openshift-ansible}"


function set-hosts-file() {
cat << EOF | sudo tee ${ANSIBLE_HOSTS}
${ANSIBLE_HOST}

# Create an OSEv3 group that contains the master, nodes, etcd, and lb groups.
# The lb group lets Ansible configure HAProxy as the load balancing solution.
# Comment lb out if your load balancer is pre-configured.
[OSEv3:children]
masters
nodes

[OSEv3:vars]
ansible_ssh_user=vagrant
# deployment_type=origin
deployment_type=openshift-enterprise
openshift_disable_check=disk_availability,docker_storage,package_version,package_availability
ansible_become=yes
openshift_uninstall_images=False
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
openshift_master_default_subdomain=example.com
#### Service catalog vars

openshift_service_catalog_image_prefix=openshift/origin-
openshift_service_catalog_image_version=latest

openshift_enable_service_catalog=True
# openshift_service_catalog_remove=True
# openshift_service_catalog_broker_remove=False

#### Service broker vars
# ansible_service_broker_image_prefix=docker.io/ansibleplaybookbundle/
# ansible_service_broker_etcd_image_prefix=registry.access.redhat.com/rhel7/
# ansible_service_broker_registry_type=dockerhub
# ansible_service_broker_registry_url="{{ lookup('env','REGISTRY_URL') }}"
# ansible_service_broker_registry_user="{{ lookup('env','REGISTRY_USER') }}"
# ansible_service_broker_registry_password="{{ lookup('env,'REGISTRY_PASSWORD') }}"
# ansible_service_broker_registry_organization=ansibleplaybookbundle

openshift_hosted_etcd_storage_kind=nfs
openshift_hosted_etcd_storage_access_modes=['ReadWriteOnce']
openshift_hosted_etcd_storage_host="{{ lookup('env','NFS_HOST') }}"
openshift_hosted_etcd_storage_nfs_directory="{{ lookup('env','NFS_DIR' }}"
openshift_hosted_etcd_storage_volume_name=etcd
openshift_hosted_etcd_storage_volume_size=1Gi
openshift_hosted_etcd_storage_labels={'storage': 'etcd'}

#### Service catalog vars

openshift_use_openshift_sdn=False

# Variables for the aos-ansible playbooks:
aos_repo=https://mirror.openshift.com/enterprise/enterprise-3.6/latest/RH7-RHAOS-3.6/x86_64/os

rhsub_pass="{{ lookup('env','RHSUB_PASS') }}"
rhsub_pool="Employee SKU*"
rhsub_user="{{ lookup('env','RHSUB_USER') }}"
rhel_skip_subscription='no'

package_version="3.6"


# host group for masters
[masters]
master

# host group for nodes, includes region info
[nodes]
${ANSIBLE_NODES}
EOF
}

function read-vagrant-inventory() {
    declare -a host_list
    ansible_host=""
    echo "Cluster info:"
    while  read -r line || [[ -n "$line" ]]; do
        echo "    $line"
        case $line in
            *"HostName"*)
                ip=$(echo $line | cut -d ' ' -f 2)
                ;;
            "Host"*)
                hostname=$(echo $line | cut -d ' ' -f 2)
                ;;
            *"Port"*)
                port=$(echo $line | cut -d ' ' -f 2)
                ;;
            *"IdentityFile"*)
                ssh_key_path=$(echo $line | cut -d ' ' -f 2)
                ;;
            *"UserKnownHostsFile"*)
                ;;
            *"User"*)
                user=$(echo $line | cut -d ' ' -f 2)
                ;;
            *"LogLevel"*)
                if [[ ! -z $add_host ]]; then
                    ANSIBLE_HOST=$(echo -e "${add_host}${ANSIBLE_HOST}")
                fi
                if [[ ! -z $add_node ]]; then
                    ANSIBLE_NODES=$(echo -e "${add_node}${ANSIBLE_NODES}")
                fi
                ;;
           *)
        esac
        add_host="${hostname} ansible_ssh_host=${ip} ansible_ssh_port=${port} ansible_ssh_user=${user} ansible_ssh_private_key_file=${ssh_key_path}\n"

        if [[ "${hostname}" == "master" ]]; then
            add_node="${hostname} openshift_node_labels=\"{'region': 'infra', 'zone': 'default'}\" openshift_schedulable=true\n"
        else
            add_node="${hostname} openshift_node_labels=\"{'region': 'primary', 'zone': 'east'}\"\n"
        fi

    done < "$1"
}

function prepare-env() {
    vagrant ssh-config > /tmp/cluster-info
    read-vagrant-inventory /tmp/cluster-info
    set-hosts-file
}

function start-cluster() {
    ansible-playbook "${OPENSHIFT_ANSIBLE_DIR}/playbooks/byo/config.yml" --sudo
}

function run-catalog-installer() {
    ansible-playbook "${OPENSHIFT_ANSIBLE_DIR}/playbooks/byo/openshift-cluster/service-catalog.yml" --sudo
}

function run-catalog-uninstaller() {
    ansible-playbook "${OPENSHIFT_ANSIBLE_DIR}/playbooks/byo/openshift-cluster/service-catalog.yml" --sudo -e 'ansible_service_broker_remove=true' -e 'openshift_service_catalog_remove=true'
}
