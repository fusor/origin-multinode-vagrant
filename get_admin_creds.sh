#/bin/sh

set -e
# Setting up oc/kubectl creds
mkdir -p ${HOME}/.kube

if [ -f ${HOME}/.kube/config ]; then
    echo "Previous config found, backing it up"
    mv -v ${HOME}/.kube/config ${HOME}/.kube/config.$(date "+%F-%T")
fi

echo "Getting config from master"
vagrant ssh master -c "sudo cat .kube/config" > ${HOME}/.kube/config
eth1=$(vagrant ssh master -c "ip addr | grep eth0 | grep inet ")

eth1=$(echo $eth1 | awk '{print $2}' | sed -e 's/\/.*$//')
echo $eth1
sed -i "s/localhost/$eth1/" ${HOME}/.kube/config

echo "Clients should now be ready to access the Kubernetes cluster"
