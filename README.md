# origin-multinode-vagrant

This repository stands up a 3 node origin cluster with CentOS as the base images. It uses vagrant snapshots hosted on AWS to quickly bring up an origin cluster ready to be used.

The origin cluster by default has a user 'admin' with password 'admin' which has full cluster privileges.

# To run:
```
vagrant up
```

# Cluster information:
```
hostname: master.example.com
IP: 192.168.156.5
User: admin
pass: admin
```
# Deploying an Ansible Service Broker inside the cluster
Note: This requires docker installed on the host that this script is run.
```
./deploy_broker.sh <dockerhub_user> <dockerhub_password>
```

# Common issues:
If iptables is running or some firewall, the default IP address used in the deploy_broker script may not be accessible from within the docker network on your host. To fix this you can run the following command on your host:
``` 
sudo iptables -I FORWARD -d 192.168.156.0/24 -j ACCEPT
```
