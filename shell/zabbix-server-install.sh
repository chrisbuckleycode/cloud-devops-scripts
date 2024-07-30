#!/bin/bash
##
## FILE: zabbix-server-install.sh
##
## DESCRIPTION: Installs Zabbix Server on Ubuntu 22.04, choices: Apache web server, MySQL database.
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: zabbix-server-install.sh
##

# Reference:
# https://www.zabbix.com/download?zabbix=6.0&os_distribution=ubuntu&os_version=24.04&components=server_frontend_agent&db=mysql&ws=apache

# Set the database password
DB_PASSWORD="password"

# Check if running with sudo
if [ "$(id -u)" != "0" ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Display a warning prompt
echo "This install will take approx. one hour!"
echo "Especially when doing schema and data import process. If ready then..."
echo "Press Enter to continue..."
read -r

# Install Zabbix repository
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb
apt update

# Install Zabbix server, frontend, agent
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
systemctl reload apache2
apt install -y mysql-server

# Mysql commands to create db, user etc.
mysql -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
mysql -e "create user zabbix@localhost identified by '$DB_PASSWORD';"
mysql -e "grant all privileges on zabbix.* to zabbix@localhost;"
mysql -e "set global log_bin_trust_function_creators = 1;"

# Import initial schema and data
echo "Running sql script to import schema and data..."
echo "mysql warning is normal, please wait up to one hour..."
echo "If not completed after one hour due to hanging, quit and re-run script"
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix -p$DB_PASSWORD zabbix

# Disable log_bin_trust_function_creators option
mysql -e "set global log_bin_trust_function_creators = 1;"

# Configure the database at /etc/zabbix/zabbix_server.conf
sed -i "s/# DBPassword=/DBPassword=$DB_PASSWORD/g" /etc/zabbix/zabbix_server.conf

# Start Zabbix server and agent processes
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2

# Instructions
echo "Now do the following:"
echo ""
echo "- On your laptop, port forward from the remote machine to your laptop. Example:"
echo "  ssh -L 8080:localhost:80 cloud_user@1.2.3.4"
echo ""
echo "- On your laptop browser, access Apache home page and Zabbix site at:"
echo "  http://127.0.0.1:8080/"
echo "  http://127.0.0.1:8080/zabbix/"
echo ""
echo "- Follow the Zabbix wizard. Accept the defaults but remember to specify your database password."
echo ""
echo "- At the logon page, the default credentials are username: Admin; password: zabbix"
