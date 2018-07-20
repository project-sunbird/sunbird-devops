#!/bin/sh
# Build script
# set -o errexit

ansible_version=2.5.0.0

# Checking for ansible
case "$(ansible --version 2> /dev/null | head -n1)" in 
    *2.5.0*)
        ;;
     *)
    # Install Ansible
    sudo apt update 
    sudo apt install -y  python python-pkg-resources python-pip
    sudo pip install ansible==$ansible_version
    ;;
esac
