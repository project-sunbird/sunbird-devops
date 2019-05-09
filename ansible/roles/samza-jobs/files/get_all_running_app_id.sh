#!/usr/bin/env bash
./yarn application -list | cut -f 2 | sed 1,'/Application-Name/'d