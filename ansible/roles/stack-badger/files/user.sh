#!/bin/bash

echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('{{badger_admin_user}}', '{{badger_admin_email}}', '{{badger_admin_password}}')" |  python /badger/code/manage.py shell 2> /dev/null
