#!/bin/bash
##
## FILE: 6.workstation-init-cloud_user-sudo.sh
##
## DESCRIPTION: Sets Up Ansible Workstation (run as cloud_user, sudo).
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: 6.workstation-init-cloud_user-sudo.sh
##

# tested on:
# CentOS Linux 7 (Core) x86_64
# AWS EC2 t3.micro

# ----- run as cloud_user, run with sudo -----
# --------------------------------------------


# create ansible user and set password
# temporary plaintext password assignment, not best security practice!
useradd ansible
echo P@ssword1! | passwd ansible --stdin

# append to /etc/sudoers
echo "ansible ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)

# dns configuration
# Append to /etc/hosts file
# needs to be in /etc/sudoers already!
echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "# Host configuration for Ansible Controller and/or Workstations" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "$1   control" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "192.168.1.123   randomhost" | sudo tee --append /etc/hosts 2> /dev/null
