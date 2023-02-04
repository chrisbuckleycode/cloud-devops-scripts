#!/usr/bin/env bash

# tested on:
# CentOS Linux 7 (Core) x86_64
# AWS EC2 t3.micro

# ----- run as ansible, sudo NOT required -----
# ---------------------------------------------


# create sample playbook
cat <<EOF> ~/workstation-setup.yml
--- # install packages workstation host
- hosts: workstation
  become: true
  tasks:
    - name: install packages via yum task
      yum:
        name: git
        state: latest
EOF

# run playbook on inventoried hostnames
# Host key checking disabled, temporary fix, feature add to backlog
ansible-playbook --inventory ~/inventory ~/workstation-setup.yml --ssh-common-args='-o StrictHostKeyChecking=no'
