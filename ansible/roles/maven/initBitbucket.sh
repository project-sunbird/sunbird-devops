#!/bin/bash

wget https://raw.githubusercontent.com/tecris/backup/v16.02.01/configureBitbucket.sh
chmod 744 configureBitbucket.sh
./configureBitbucket.sh
rm configureBitbucket.sh
