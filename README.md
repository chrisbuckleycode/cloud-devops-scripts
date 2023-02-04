# cloud-devops-scripts
Cloud/DevOps related code/scripts too small to deserve it's own repo
e.g. bash/shell, python, ansible
For public cloud see elsewhere
e.g. cloud-devops-aws, cloud-devops-azure


## Initialize Controller (One Time)

cloud_user@control
```
curl -sf -L https://raw.githubusercontent.com/chrisbuckleycode/cloud-devops-scripts/ansible/1.control-init-cloud_user-sudo.sh | sudo bash
```

ansible@control
```
curl -sf -L https://raw.githubusercontent.com/chrisbuckleycode/cloud-devops-scripts/ansible/2.control-init-ansible.sh | bash
```

## Add Workstation (Repeat for Every New)

cloud_user@workstation
```
CONTROL="192.168.1.100"
curl -sf -L https://raw.githubusercontent.com/chrisbuckleycode/cloud-devops-scripts/ansible/6.workstation-init-cloud_user-sudo.sh | sudo bash $CONTROL
```

ansible@control
```
WORKSTATION="192.168.1.8"
curl -sf -L https://raw.githubusercontent.com/chrisbuckleycode/cloud-devops-scripts/ansible/7.control-addworkstation-ansible.sh | bash $WORKSTATION
```

## Deploy Playbooks (Ad Hoc)

ansible@control
```
curl -sf -L https://raw.githubusercontent.com/chrisbuckleycode/cloud-devops-scripts/ansible/8.control-pushplaybook-ansible.sh | bash
```
