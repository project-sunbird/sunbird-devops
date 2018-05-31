#!/bin/sh

# Author: Rajesh Rajendran<rjshrjndrn@gmail.com>

# Creating DB Scehma
/badger/code/manage.py migrate

# Running server
/badger/code/manage.py runserver 0.0.0.0:8004

exec $@
