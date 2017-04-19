#!/bin/sh

export ANSIBLE_TIMEOUT=60
vagrant up --no-provision $@ \
    && ./fix_ip_addresses.sh \
    && vagrant provision 
