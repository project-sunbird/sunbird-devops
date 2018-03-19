#!/bin/sh
# Build script
# set -o errexit

ansible_version=2.4.1.0

# Checking for ansible
case "$(ansible --version | head -n1)" in 
    *2.4.1.0*)
        ;;
     *)
    # Install Ansible
    sudo apt install -y python-pip
    sudo pip install ansible==$ansible_version
    ;;
esac
