#!/bin/bash
cd "$(dirname "$0")" # Go to the script's directory

export READING_CLIENT_EU=($(gcloud compute instances list --filter="tags:reading-client AND tags:eu" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))
export READING_CLIENT_AUS=($(gcloud compute instances list --filter="tags:reading-client AND tags:aus" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

# declare array for writing clients.
declare -a IPS=($(gcloud compute instances list --filter="tags.items=writing-client" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

# Get all the replica ips, so the reading client knows where to request information.
declare -a REPLICAS_EU=($(gcloud compute instances list --filter="tags:replica AND tags:eu" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

declare -a REPLICAS_AUS=($(gcloud compute instances list --filter="tags:replica AND tags:aus" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

# Get ip of primary.
export PRIMARY=($(gcloud compute instances list --filter="tags.items=primary" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

# get index of the array, to allow the host file diferenciate between replicas.
index() {
  [[ "${moCurrent#*.}"  ]] && echo "$((${moCurrent#*.} + 1))"
}

export IPS=$IPS
export REPLICAS_EU=$REPLICAS_EU
export REPLICAS_AUS=$REPLICAS_AUS

. ./mo
cat ansible/clients_host_template.yml | mo > clients_hosts.yml