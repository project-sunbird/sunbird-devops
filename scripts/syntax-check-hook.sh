#!/bin/bash

checkSyntax(){
filenames=$(git diff --cached --name-only --diff-filter=ACM)
flag=0
for i in $filenames
do
  if [[ "$i" =~ (.yaml|.yml) ]]; then
    ansible-playbook -i ./ansible/inventories/sample --syntax-check $i
    if [[ $? -ne 0 ]]; then
      flag=1
    fi
  fi
done

if [[ $flag -eq 1 ]]; then
  echo -e "\e[1;36m\nAnsible syntax error found. Please correct these and then commit.\e[0;37m"
  exit 1
fi
}

checkSyntax
