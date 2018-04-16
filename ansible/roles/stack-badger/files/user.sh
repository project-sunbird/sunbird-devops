#!/bin/bash

# Checking for container
container=$(docker ps | grep badger | awk '{print $1}')

docker exec $container python /badger/code/manage.py migrage
docker exec $container  echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('{{badger_admin_user}}', '{{badger_admin_email}}', '{{badger_admin_password}}')" |  python manage.py shell
