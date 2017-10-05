if grep -q Alpine /etc/os-release; then
    apk -v --update --no-cache add jq
    apk -v add ansible=2.3.0.0-r1
else
    sudo apt-get update -y
    sudo apt-get -y install software-properties-common
    sudo apt-add-repository ppa:ansible/ansible -y
    sudo apt-get update -y
    sudo apt-get -y install ansible
fi
