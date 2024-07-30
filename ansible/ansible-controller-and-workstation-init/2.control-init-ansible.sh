#!/bin/bash
##
## FILE: 2.control-init-cloud_user-sudo.sh
##
## DESCRIPTION: Sets Up Ansible Control Node (run as ansible).
##
## AUTHOR: Chris Buckley (github.com/chrisbuckleycode)
##
## USAGE: 2.control-init-cloud_user-sudo.sh
##

# tested on:
# CentOS Linux 7 (Core) x86_64
# AWS EC2 t3.micro

# ----- run as ansible, sudo NOT required -----
# ---------------------------------------------


# generate key
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
