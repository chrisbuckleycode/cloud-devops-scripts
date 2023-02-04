# edit dns to add control


# create ansible user and set password
sudo useradd ansible
sudo passwd ansible

sudo visudo
add to end: ansible ALL=(ALL) NOPASSWD: ALL
