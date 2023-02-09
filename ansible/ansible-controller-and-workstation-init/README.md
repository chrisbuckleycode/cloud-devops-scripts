# Ansible

## Initialize Controller (One Time)

cloud_user@control
```
curl -sf -L https://raw.githubusercontent.com/chrisbuckleycode/cloud-devops-scripts/main/ansible/ansible-controller-and-workstation-init/1.control-init-cloud_user-sudo.sh | sudo bash
```

ansible@control
```
su ansible
curl -sf -L https://raw.githubusercontent.com/chrisbuckleycode/cloud-devops-scripts/main/ansible/ansible-controller-and-workstation-init/2.control-init-ansible.sh | bash
```

## Add Workstation (Repeat for Every New)

cloud_user@workstation
```
CONTROL="192.168.1.100"
curl -sf -L https://raw.githubusercontent.com/chrisbuckleycode/cloud-devops-scripts/main/ansible/ansible-controller-and-workstation-init/6.workstation-init-cloud_user-sudo.sh | sudo bash -s -- $CONTROL
```

ansible@control
```
WORKSTATION="192.168.1.8"
curl -sf -L https://raw.githubusercontent.com/chrisbuckleycode/cloud-devops-scripts/main/ansible/ansible-controller-and-workstation-init/7.control-addworkstation-ansible.sh | bash -s -- $WORKSTATION
```

## Deploy Playbooks (Ad Hoc)

ansible@control
```
curl -sf -L https://raw.githubusercontent.com/chrisbuckleycode/cloud-devops-scripts/main/ansible/ansible-controller-and-workstation-init/8.control-pushplaybook-ansible.sh | bash
```
