#!/bin/bash

sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

SERVER_INSTALL_START=$(date "+%s")
export ANSIBLE_HOST_KEY_CHECKING=False
sudo ansible-playbook -i inventory main.yml
SERVER_INSTALL_END=$(date "+%s") 

echo "Server Install time: " $((SERVER_INSTALL_END-SERVER_INSTALL_START))

exit 0
