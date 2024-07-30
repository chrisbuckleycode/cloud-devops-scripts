#!/bin/bash
##
## FILE: local-ssh-tunnel.sh
##
## DESCRIPTION: Creates SSH tunnels from laptop to bastion (for Grafana and Prometheus).
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: local-ssh-tunnel.sh
##

if [ $# -eq 0 ]; then
  echo "Please provide the k8s server public IP as an argument."
  exit 1
fi

ip_address=$1

echo "When SSH tunneling complete,"
echo "Visit:"
echo
echo "Grafana"
echo "http://localhost:3000"
echo "(username: admin"
echo "password: prom-operator)"
echo
echo "Prometheus"
echo "http://localhost:9090"
echo
echo "type \"exit\""
echo "and Ctrl-C to quit"
echo "---------------------"
echo "Enter the password for the remote host"

ssh -L 9090:localhost:9090 -L 3000:localhost:3000 cloud_user@$ip_address
