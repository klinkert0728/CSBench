#!/usr/bin/env bash

set -euo pipefail

keypair_name=$1
keypair_file=$2

READING_CLIENT=($(gcloud compute instances list --filter="tags.items=reading-client" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))
declare -a IPS=($(gcloud compute instances list --filter="tags.items=writting-client" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

./configureBenchmarkClientsHostfile.sh $READING_CLIENT ${IPS[@]}

ansible-playbook -i clients_hosts.yml ansible/configureBenchmarkClients.yml --ssh-common-args='-o StrictHostKeyChecking=no'