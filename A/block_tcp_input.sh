#!/bin/bash

if [  $# -lt 2 ] 
then
    echo -e "\033[0;31mError: You must specify at least two parameters. $(date "+%m/%d/%Y %T")\033[0m" 
    exit 1
fi

apt-get install iptables -y
iptables -D INPUT -p tcp --dport $1 -j DROP

iptables -A INPUT -p tcp --dport $1 --source $2 -j ACCEPT
iptables -A INPUT -p tcp --dport $1 -j DROP