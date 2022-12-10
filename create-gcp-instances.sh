#!/usr/bin/env bash

set -euo pipefail

run=$1
NUMBER_OF_REPLICAS=$2

# set the primary name
PRIMARY_NAME=primary-experiment-$run

# define file name as id_rsa and id_rsa.pub
keypair_file="bench_dk_id_rsa"
# define keypair name used as benchUser, be aware that if you change this user, you will need to change the remote_user in all plays for ansible
keypair_name="benchUser"

# if file does not exist, generate new key pair (id_rsa, id_rsa.pub)
[[ -f "$keypair_file" ]] || {
  echo "generating ssh key..."
  # cc-default as comment and no passphrase in files id_rsa and id_rsa.pub
  ssh-keygen -t rsa -C "$keypair_name" -f "./$keypair_file" -q -N ""
}

# reformat public key to match googles requirements
echo "$keypair_name:$(<./${keypair_file}.pub)" > id_rsa_formatted.pub

# set default region and zone
export CLOUDSDK_COMPUTE_REGION=europe-west1
export CLOUDSDK_COMPUTE_ZONE="${CLOUDSDK_COMPUTE_REGION}-b"

echo "starting instance..."
#CREATE VM instance
gcloud compute instances create $PRIMARY_NAME --project=csbench --image-family=debian-11 --image-project=debian-cloud  --machine-type=e2-micro --create-disk=auto-delete=yes --tags=primary

#upload ssh public key to instance
gcloud compute instances add-metadata $PRIMARY_NAME --metadata-from-file ssh-keys="./id_rsa_formatted.pub"

#ADD firewall rules for SSH and ICMP for all VM with the tag cloud computing
if gcloud compute firewall-rules list --filter="name~allow-mongo-firewall" | grep -c allow-mongo-firewall==0; then
    gcloud compute firewall-rules create "allow-mongo-firewall" --action=ALLOW --rules=icmp,tcp:22,tcp:27017 --source-ranges=0.0.0.0 --direction=INGRESS
else
    echo "firewall rule already created"
fi

# Create replicas
for i in `seq 1 $NUMBER_OF_REPLICAS`; do
  instance_name="replica-$i-experiment-$run"
  gcloud compute instances create $instance_name --project=csbench --image-family=debian-11 --image-project=debian-cloud  --machine-type=e2-micro --create-disk=auto-delete=yes --tags=replica
  gcloud compute instances add-metadata $instance_name --metadata-from-file ssh-keys="./id_rsa_formatted.pub"
done

echo "Wait for the instances to spin up"
sleep 30

# Configure environment
./configure_environment.sh $keypair_name $keypair_file