#!/bin/sh
# Build script
# set -o errexit

#!/bin/sh
# Build script
# set -o errexit
set -e
env=${ENV:-null}

ansible-playbook --version
ansible-playbook --limit $HOST_PATTERN -i ansible/inventory/ntp-production ansible/run_command.yml --vault-password-file "/run/secrets/vault-pass" -vvvv --extra-vars "command=\"$COMMAND\""