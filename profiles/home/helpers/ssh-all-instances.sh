#!/bin/bash

filter=$1
cmd=$2
key=$3

for ip in $(aws ec2 describe-instances --filters Name='tag:Name',Values="$filter" --query 'Reservations[*].Instances[*].PrivateIpAddress' --region us-east-1 --output text); do
    name=$(aws ec2 describe-instances --filters Name='private-ip-address',Values="$ip" --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value | [0]' --region us-east-1 --output text)
    keyfilter=$(echo $name | awk -F'-' '{print $6}')
    if [[ "$key" == "" ]]; then
      case $keyfilter in
          sg) key='hzn-neo4j-dev';;
          ha) key='hzn-neo4j-dev-frm-ha';;
          cc) key='hzn-neo4j-dev-frm-cc';;
      esac
    fi

    echo "Name: $name"
    ssh -i "${key}" -tt $ip "$cmd"

done
