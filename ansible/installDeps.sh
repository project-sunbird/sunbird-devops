if grep -q Alpine /etc/os-release; then
    apk -v --update --no-cache add jq
    apk -v add ansible=2.3.0.0-r1
else
    sudo apt-get update
    sudo apt-get install software-properties-common
    sudo apt-add-repository ppa:ansible/ansible
    sudo apt-get update
    sudo apt-get install ansible
fi

