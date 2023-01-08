#!/usr/bin/env bash

set -euo pipefail


# set default region and zone
export CLOUDSDK_COMPUTE_REGION=europe-west1
export CLOUDSDK_COMPUTE_ZONE="${CLOUDSDK_COMPUTE_REGION}-b"

# Read ssh key
keypair_file=$1
# User for ssh
keypair_name=$2

# Allow user to differenciate the client
writting_client_number=$3

# Attach the client to a current run
run=$4

instance_name="writing-client-$writting_client_number-experiment-$run"
gcloud compute instances create $instance_name --project=csbench --image-family=debian-11 --zone=$CLOUDSDK_COMPUTE_ZONE --image-project=debian-cloud  --machine-type=e2-medium --create-disk=auto-delete=yes --tags=$instance_name
gcloud compute instances add-metadata $instance_name  --zone=$CLOUDSDK_COMPUTE_ZONE --metadata-from-file ssh-keys="./id_rsa_formatted.pub"

sleep 20
CLIENT=($(gcloud compute instances list --filter="tags.items=$instance_name" --format="value(EXTERNAL_IP)"  | tr '\n' ' '))

./configureWrittingClientHostFile.sh $CLIENT
 
 