#!/bin/bash
# System Health check
# set -o errexit
export TERM=xterm-color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

export COLOR_NC='\e[0m' # No Color
export COLOR_WHITE='\e[1;37m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_GRAY='\e[0;30m'
export COLOR_LIGHT_GRAY='\e[0;37m'

export L="\n*******************************\n"

clear
echo -e $COLOR_WHITE$L"VM CHECKS"$L
echo -e $COLOR_GREEN"Date: " $COLOR_NC$(date +%c)
echo -e $COLOR_GREEN"OS: " $COLOR_NC$(uname -srm)
echo -e $COLOR_GREEN"Uptime:" $COLOR_NC$(/usr/bin/uptime)
echo -e $COLOR_GREEN"RAM:" $COLOR_NC
/usr/bin/free -m
echo -e $COLOR_GREEN"Testing internet connectivity:" $COLOR_NC
curl -sSf https://github.com/project-sunbird/sunbird-devops > /dev/null
echo -e $COLOR_GREEN"Checked" $COLOR_NC
echo -e $COLOR_GREEN"Disk Usage:" $COLOR_NC
/bin/df -h
echo -e $COLOR_GREEN"CPU Usage:" $COLOR_NC
mpstat
echo -e $COLOR_GREEN"Zombie processes:" $COLOR_NC
ps -eo stat,pid|grep -w Z|awk '{print $2}'
echo -e $COLOR_GREEN"RAM Usage:" $COLOR_NC
free -m
echo -e $COLOR_GREEN"TOP Memory hoggers:" $COLOR_NC
ps -eo pmem,pcpu,pid,ppid,user,stat,args | sort -k 1 -r | head -6|sed 's/$/\n/'
echo -e $COLOR_GREEN"TOP CPU hoggers:" $COLOR_NC
ps -eo pcpu,pmem,pid,ppid,user,stat,args | sort -k 1 -r | head -6|sed 's/$/\n/'

if command -v docker 2>/dev/null; then
    echo -e $COLOR_WHITE$L"DOCKER CHECKS"$L
    echo -e $COLOR_GREEN"Version: " $COLOR_NC$(docker -v)
else
    echo -e $COLOR_RED$L"Skipping DOCKER CHECKS"$L  $COLOR_NC
fi

if command -v docker swarm 2>/dev/null; then
    echo -e $COLOR_WHITE$L"SWARM CHECKS"$L
    echo -e $COLOR_GREEN"Nodes: "  $COLOR_NC
    docker node ls
    echo -e $COLOR_GREEN"Services: "  $COLOR_NC
    docker service ls
    echo -e $COLOR_GREEN"Networks: "  $COLOR_NC
    docker network ls
    echo -e $COLOR_GREEN"Configs: "  $COLOR_NC
    docker config ls
    echo -e $COLOR_GREEN"Stats: "  $COLOR_NC
    docker stats --no-stream
else
    echo -e $COLOR_RED$L"Skipping SWARM CHECKS"$L  $COLOR_NC
fi

