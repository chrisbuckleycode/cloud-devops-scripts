#!/bin/bash
##
## FILE: 7.control-addworkstation-ansible.sh
##
## DESCRIPTION: Adds Ansible Workstation to Control Node (run as ansible).
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: 7.control-addworkstation-ansible.sh
##

# tested on:
# CentOS Linux 7 (Core) x86_64
# AWS EC2 t3.micro

# ----- run as ansible, sudo NOT required -----
# ---------------------------------------------


# dns configuration
# Append to /etc/hosts file
# needs to be in /etc/sudoers already!
echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "# Host configuration for Ansible Controller and/or Workstations" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "$1   workstation" | sudo tee --append /etc/hosts 2> /dev/null && \
echo "192.168.1.8   workstation3" | sudo tee --append /etc/hosts 2> /dev/null

# make sure ansible account already exists on remote machine!
# copy public key to workstation
# temporary plaintext password assignment, not best security practice!
sshpass -p P@ssword1! ssh-copy-id ansible@workstation -p 22

# create inventory: append workstation hostname to end of file
echo 'workstation' >> ~/inventory
