#!/usr/bin/env bash

set -euo pipefail

keypair_name=$1
keypair_file=$2

declare -a READING_CLIENTS=($(gcloud compute instances list --filter="tags.items=reading-client" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))
declare -a IPS=($(gcloud compute instances list --filter="tags.items=writing-client" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

./configureBenchmarkClientsHostfile.sh ${READING_CLIENTS[@]} ${IPS[@]}

ansible-playbook -i clients_hosts.yml ansible/configureBenchmarkClients.yml --ssh-common-args='-o StrictHostKeyChecking=no'