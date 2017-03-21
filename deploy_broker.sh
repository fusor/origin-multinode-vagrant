#!/bin/bash

OPENSHIFT_TARGET="192.168.156.5:8443"
OPENSHIFT_USER="admin"
OPENSHIFT_PASS="admin"
DOCKERHUB_USER=$1
DOCKERHUB_PASS=$2

if [ -z $1 ]; then
  echo "Usage: ./deploy_broker.sh <dockerhub_user> <dockerhub_pass>"
  exit
elif [ -z $2 ]; then
  echo "Usage: ./deploy_broker.sh <dockerhub_user> <dockerhub_pass>"
  exit
fi

echo "Checking if docker is installed..."

rpm -q docker > /dev/null
if [ $? != 0 ]
then
  echo "Docker is not installed on this machine, please install it and run the service before running this script."
  exit;
else
  echo "Docker exists, continuing."
fi;

docker run -e "OPENSHIFT_TARGET=$OPENSHIFT_TARGET" \
           -e "OPENSHIFT_USER=$OPENSHIFT_USER" \
           -e "OPENSHIFT_PASS=$OPENSHIFT_PASS" \
           ansibleapp/ansible-service-broker-ansibleapp provision\
           -e "dockerhub_user=$DOCKERHUB_USER" \
           -e "dockerhub_pass=$DOCKERHUB_PASS" \
           -e "openshift_target=$OPENSHIFT_TARGET" \
           -e "openshift_user=$OPENSHIFT_USER" \
           -e "openshift_pass=$OPENSHIFT_PASS"
