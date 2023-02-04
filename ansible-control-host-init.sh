#!/usr/bin/env bash

-----  run with sudo ----------------------------
# edit /etc/hosts to add workstation

# tested on:
# CentOS Linux 7 (Core) x86_64
# AWS EC2 t3.micro

# install ansible
yum install -y epel-release
yum install -y ansible

# create ansible user and set password
# Temporary password assign, not best security practice!
echo P@ssword1! | passwd ansible --stdin

------- as ansible user --------
# generate key and copy to 'workstation' host
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
ssh-copy-id workstation

# create inventory: append workstation hostname to end of file
touch ~/inventory
# Add the text "workstation" to the file
echo 'workstation' >> inventory

# create sample playbook
cat <<EOF> ~/git-setup.yml
--- # install packages workstation host
- hosts: workstation
  become: true
  tasks:
    - name: install packages via yum task
      yum:
        name: git
        state: latest
EOF


ansible-playbook -i ~/inventory /home/ansible/git-setup.yml
