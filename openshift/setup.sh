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

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
ansible_ssh_user=vagrant
deployment_type=origin

#openshift_release=1.4

# Uncomment the following to enable htpasswd authentication; defaults to
# DenyAllPasswordIdentityProvider.
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
openshift_master_default_subdomain=apps.example.com

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
