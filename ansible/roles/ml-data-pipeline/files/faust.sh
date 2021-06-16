#!/bin/sh
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
/opt/sparkjobs/spark_venv/bin/python /opt/sparkjobs/source/\$1.py --workdir /opt/sparkjobs/source/\$2 worker -l info

