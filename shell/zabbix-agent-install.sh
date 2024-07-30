#!/bin/bash
##
## FILE: zabbix-agent-install.sh
##
## DESCRIPTION: Installs Zabbix agent2 on Ubuntu 22.04.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: zabbix-agent-install.sh
##

# Reference:
# https://www.zabbix.com/download?zabbix=6.0&os_distribution=ubuntu&os_version=22.04&components=agent_2&db=&ws=

# Specify the current server hostname
SERVER_HOSTNAME="zabbixserver"

# Specify the current server private IP
SERVER_IP="1.2.3.4"

# Check if running with sudo
if [ "$(id -u)" != "0" ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Install Zabbix repository
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb
apt update

# Install Zabbix agent2
apt install zabbix-agent2 zabbix-agent2-plugin-*

# Edit agent configuration file with server details
CONFIG_FILE="/etc/zabbix/zabbix_agent2.conf"
sed -i "s/^Server=127.0.0.1/Server=$SERVER_IP/" "$CONFIG_FILE"
sed -i "s/^ServerActive=127.0.0.1/ServerActive=$SERVER_IP/" "$CONFIG_FILE"
sed -i "s/^Hostname=Zabbix server/Hostname=$SERVER_HOSTNAME/" "$CONFIG_FILE"

# Enable and start agent2 process, show status
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2
systemctl status zabbix-agent2
echo "You should see confirmation of enabled and started service above"

# Allow firewall port 10050 and show status
ufw allow 10050/tcp
ufw status verbose | grep 10050
netstat -tulpn | grep 10050
echo "You should see confirmation of open port 10050 above"

# Instructions
echo "Now do the following:"
echo ""
echo "- On the Zabbix server you should be able to telnet to the target VM (connection will close but should get some output). Example:"
echo "  telnet <IP> 10050"
echo ""
echo "- Go to the Zabbix server web UI menu and Configuration, Hosts, Create host"
