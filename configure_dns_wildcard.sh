#!/bin/sh

if [[ $EUID -ne 0 ]]; then
    echo "You must be a root user to run" 2>&1
    exit 1
fi

service NetworkManager stop

grep -q -F 'dns=dnsmasq' /etc/NetworkManager/NetworkManager.conf || sed -i '/\[main\]/a dns=dnsmasq' /etc/NetworkManager/NetworkManager.conf
mkdir -p /etc/NetworkManager/dnsmasq.d
touch /etc/NetworkManager/dnsmasq.d/local-development.conf
(grep -q -F 'address=/example' /etc/NetworkManager/dnsmasq.d/local-development.conf && \
  sed -i -e 's|address=/.*|address=/example.com/192.168.156.5|' /etc/NetworkManager/dnsmasq.d/local-development.conf) || \
  echo "address=/example.com/192.168.156.5" >> /etc/NetworkManager/dnsmasq.d/local-development.conf

service NetworkManager restart
