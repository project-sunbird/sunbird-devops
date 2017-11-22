#!/bin/sh

set -e

cd ansible
for playbook_yaml in *.yml; do
  ansible-playbook -i inventories/sample $playbook_yaml --syntax-check -e "hosts=dummy"
done