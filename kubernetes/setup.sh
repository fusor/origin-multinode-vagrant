#!/bin/bash

ANSIBLE_HOSTS="/etc/ansible/hosts"
# Playbook:
# https://github.com/sjenning/kubeadm-playbook
KUBERNETES_ANSIBLE_DIR="${KUBERNETES_ANSIBLE_DIR:-${PROJECT_ROOT}/kubeadm-playbook}"

function set-hosts-file() {
cat << EOF | sudo tee ${ANSIBLE_HOSTS}
${ANSIBLE_HOST}

[master]
master

[node]
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
            add_node=""
        else
            add_node="${hostname}\n"
        fi

    done < "$1"
}

function prepare-env() {
    vagrant ssh-config > /tmp/cluster-info
    read-vagrant-inventory /tmp/cluster-info
    set-hosts-file
}

function start-cluster() {
    ansible-playbook "${KUBERNETES_ANSIBLE_DIR}/site.yml"
}
