#!/bin/bash

#
# The vagrant snapshot'd images we assigned IPv4 address for eth0 interface via dhcp
# at their time of image creation.  However, due to the nature of dhcp, when these 
# vagrant boxes are reused, the eth0 ip addr will often NOT be the same as the original.
# This causes Openshift Origin router to not properly resolve names and ip's, due the 
# ip address not matching up correctly.
#
# The below is a 'Quick & Dirty' way to change the IP address for the Origin configuration 
# files, so that the ip addrs in the confiuration files match the ones currently assigned 
#

#########################
# Master Node
#########################

# get the eth0 ip address for the master node
CMD="ip addr list eth0 |grep \"inet \" |cut -d' ' -f6|cut -d/ -f1"
MASTER_IP=`vagrant ssh master -c "${CMD}"`

# edit the origin configuration file
FILE='/etc/origin/master/master-config.yaml'
OLD_TXT="  - 192.168.121"
NEW_TXT="  - ${MASTER_IP}"
CMD="sudo sed -i '/${OLD_TXT}/c\\${NEW_TXT}\'  ${FILE}"
vagrant ssh master -c "${CMD}"

OLD_TXT="  masterIP: 192.168.121"
NEW_TXT="  masterIP: ${MASTER_IP}"
CMD="sudo sed -i '/${OLD_TXT}/c\\${NEW_TXT}\'  ${FILE}"
vagrant ssh master -c "${CMD}"

# restart the origin service
CMD="sudo systemctl restart origin-master"
vagrant ssh master -c "${CMD}"

#########################
# Node1
#########################

# get the eth0 ip address for node1
CMD="ip addr list eth0 |grep \"inet \" |cut -d' ' -f6|cut -d/ -f1"
NODE1_IP=`vagrant ssh node1 -c "${CMD}"`

# edit the origin configuration file
FILE='/etc/origin/node/node-config.yaml'
OLD_TXT="dnsIP: 192.168.121"
NEW_TXT="dnsIP: ${NODE1_IP}"
CMD="sudo sed -i '/${OLD_TXT}/c\\${NEW_TXT}\'  ${FILE}"
vagrant ssh node1 -c "${CMD}"

# restart the origin service
CMD="sudo systemctl restart origin-node"
vagrant ssh node1 -c "${CMD}"

#########################
# Node2
#########################

# get the eth0 ip address for node2
CMD="ip addr list eth0 |grep \"inet \" |cut -d' ' -f6|cut -d/ -f1"
NODE2_IP=`vagrant ssh node2 -c "${CMD}"`

# edit the origin configuration file
FILE='/etc/origin/node/node-config.yaml'
OLD_TXT="dnsIP: 192.168.121"
NEW_TXT="dnsIP: ${NODE2_IP}"
CMD="sudo sed -i '/${OLD_TXT}/c\\${NEW_TXT}\'  ${FILE}"
vagrant ssh node2 -c "${CMD}"

CMD="sudo systemctl restart origin-node"
vagrant ssh node2 -c "${CMD}"

#########################
# Node3
#########################

# get the eth0 ip address for node3
CMD="ip addr list eth0 |grep \"inet \" |cut -d' ' -f6|cut -d/ -f1"
NODE3_IP=`vagrant ssh node3 -c "${CMD}"`

FILE='/etc/origin/node/node-config.yaml'
OLD_TXT="dnsIP: 192.168.121"
NEW_TXT="dnsIP: ${NODE3_IP}"
CMD="sudo sed -i '/${OLD_TXT}/c\\${NEW_TXT}\'  ${FILE}"
vagrant ssh node3 -c "${CMD}"

# restart the origin service
CMD="sudo systemctl restart origin-node"
vagrant ssh node3 -c "${CMD}"
