#!/bin/bash
cd "$(dirname "$0")" # Go to the script's directory

export READING_CLIENT_EU=$1
export READING_CLIENT_AUS=$2

# declare array for writing clients start in the 3rd position as the first two parameters are always going to be reading clients.
declare -a IPS=()
for i in "${@:3}"; do
  IPS+=($(printf '%s' "$i"))
done

# Get all the replica ips, so the reading client knows where to request information.
declare -a REPLICAS_EU=($(gcloud compute instances list --filter="tags.items=replica,eu" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

declare -a REPLICAS_AUS=($(gcloud compute instances list --filter="tags.items=replica,aus" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

# Get ip of primary
export PRIMARY=($(gcloud compute instances list --filter="tags.items=primary" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

# get index for the array
index() {
  [[ "${moCurrent#*.}"  ]] && echo "$((${moCurrent#*.} + 1))"
}

export IPS=$IPS
export REPLICAS_EU=$REPLICAS_EU
export REPLICAS_AUS=$REPLICAS_AUS

. ./mo
cat ansible/clients_host_template.yml | mo > clients_hosts.yml