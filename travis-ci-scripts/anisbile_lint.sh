#!/bin/bash
virtualenv env;
source env/bin/activate;
pip -q install ansible;
pip -q install ansible-lint
ansible --version
ansible-playbook  --version
./test.sh
