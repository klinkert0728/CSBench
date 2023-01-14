#!/usr/bin/env bash

set -euo pipefail

keypair_name=$1
keypair_file=$2

# Get the ips of the replicas
declare -a IPS=($(gcloud compute instances list --filter="tags.items=replica" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

# Get ip of primary
PRIMARY=($(gcloud compute instances list --filter="tags.items=primary" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

# Pass the IPs to teh host file to replace the template file
./configureHostFile.sh $PRIMARY ${IPS[@]}


# Copy mongo config file to the replicas
for i in ${IPS[@]}; do
  scp -i "./$keypair_file" -o StrictHostKeyChecking=no ./ansible/mongod.conf $keypair_name@$i:~/  
done

# Copy mongo config to primary
scp -i "./$keypair_file" -o StrictHostKeyChecking=no ./ansible/mongod.conf $keypair_name@$PRIMARY:~/  

ansible-playbook -i hosts.yml ansible/configureMongo.yml --ssh-common-args='-o StrictHostKeyChecking=no'

./configurePrimaryMembers.sh $PRIMARY ${IPS[@]}