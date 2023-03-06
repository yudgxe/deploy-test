#!/bin/bash
if [  $# -lt 1 ] 
then
    echo -e "\033[0;31mError: You must specify at least one parameter. $(date "+%m/%d/%Y %T")\033[0m"
    exit 1
fi

function getPath {
    if [  $# -lt 1 ]; then
        return 1
    fi
    
    local inout=$1
    local j=0
    for (( i=${#inout} - 1; i>=0; i-- )); do
      if [ ${inout:$i:1} == "/" ]; then
        j=$i
        break
      fi
    done
    
    echo ${inout:0:j}
}

path=$(getPath $1)
mkdir -p $path

expect -c "spawn ssh-keygen -f $1 
           expect \"*(empty for no passphrase):\" { send \"\r\" }
           expect \"*?nter same passphrase again:\" { send \"\r\" }
           expect eof"