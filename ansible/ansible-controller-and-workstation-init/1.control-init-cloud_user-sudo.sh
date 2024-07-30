#!/bin/bash
##
## FILE: 1.control-init-cloud_user-sudo.sh
##
## DESCRIPTION: Sets Up Ansible Control Node (run as cloud_user, sudo).
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: 1.control-init-cloud_user-sudo.sh
##

# Insecure, not for Production use!
# tested on:
# CentOS Linux 7 (Core) x86_64
# AWS EC2 t3.micro

# ----- run as cloud_user, run with sudo -----
# --------------------------------------------


# install ansible
yum install -y epel-release
yum install -y ansible
# ansible also instals sshpass as dependency

# create ansible user and set password
# temporary plaintext password assignment, not best security practice!
useradd ansible
echo P@ssword1! | passwd ansible --stdin

# append to /etc/sudoers
echo "ansible ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)
