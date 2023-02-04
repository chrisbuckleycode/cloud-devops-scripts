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
    - name: Ignore host key on first run
      when: has_entry_in_known_hosts_file.rc == 1
      set_fact:
        ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
    - name: install packages via yum task
      yum:
        name: git
        state: latest
EOF

# run playbook on inventoried hostnames
ansible-playbook --inventory ~/inventory /home/ansible/workstation-setup.yml
