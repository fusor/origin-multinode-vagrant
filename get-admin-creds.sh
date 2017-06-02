#/bin/sh

set -e

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $PROJECT_ROOT/default-config

function error-check {
    if $ERROR; then
        cat ${HOME}/.kube/config
        exit 1
    fi
}

mkdir -p ${HOME}/.kube

if [ -f ${HOME}/.kube/config ]; then
    echo "Previous config found, backing it up"
    mv -v ${HOME}/.kube/config ${HOME}/.kube/config.$(date "+%F-%T")
fi

echo "Getting config from ${CLUSTER} master"
ERROR=false
if [[ "${CLUSTER}" == "openshift" ]]; then
    vagrant ssh master -c "sudo cat ~/.kube/config" > ${HOME}/.kube/config || ERROR=true
    if $ERROR; then
        echo "Looking for credentials in a different location"
        vagrant ssh master -c "sudo cat /etc/origin/master/admin.kubeconfig" > ${HOME}/.kube/config || ERROR=true
    fi
    error-check
elif [[ "${CLUSTER}" == "kubernetes" ]]; then
    vagrant ssh master -c "sudo cat /etc/kubernetes/admin.conf" > ${HOME}/.kube/config || ERROR=true
    error-check
fi

eth1=$(vagrant ssh master -c "ip addr | grep eth0 | grep inet")
eth1=$(echo $eth1 | awk '{print $2}' | sed -e 's/\/.*$//')
echo $eth1
sed -i "s/localhost/$eth1/" ${HOME}/.kube/config
sed -i 's/master\.example\.com/'"${eth1}"'/' ${HOME}/.kube/config

echo "Clients should now be ready to access your ${CLUSTER} cluster"
