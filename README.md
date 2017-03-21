# origin-multinode-vagrant

This repository stands up a 3 node origin cluster with Centos as the base images. It uses vagrant snapshots hosted on AWS to quickly bring up an origin cluster ready to be used.

The origin cluster by default has a user 'admin' with password 'admin' which has fully cluster privileges.

# To run:
vagrant up

# Cluster information:
```
hostname: master.example.com
IP: 192.168.156.5
User: admin
pass: admin
```
