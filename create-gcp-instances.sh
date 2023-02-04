#!/usr/bin/env bash

set -euo pipefail


run=$1 # determines the experiment run number
NUMBER_OF_REPLICAS=$2 # number of replicatas that will be created (minimum recommended 2 ). without counting the primary
NUMBER_OF_WR_CLIENTS=$3 # determines the number of benchmark clients instances that will be created.

# set the primary name
PRIMARY_NAME=primary-experiment-$run

# set reading client name
READING_CLIENT="reading-client-$run"

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

echo "starting instances..."
# create primary instance
gcloud compute instances create $PRIMARY_NAME --project=csbench --image-family=debian-11 --zone=$CLOUDSDK_COMPUTE_ZONE --image-project=debian-cloud  --machine-type=e2-medium --create-disk=auto-delete=yes --tags=primary
gcloud compute instances add-metadata $PRIMARY_NAME --zone=$CLOUDSDK_COMPUTE_ZONE --metadata-from-file ssh-keys="./id_rsa_formatted.pub"

gcloud compute instances create $READING_CLIENT --project=csbench --image-family=debian-11 --zone=$CLOUDSDK_COMPUTE_ZONE --image-project=debian-cloud  --machine-type=e2-medium --create-disk=auto-delete=yes --tags=reading-client,eu
gcloud compute instances add-metadata $READING_CLIENT --zone=$CLOUDSDK_COMPUTE_ZONE --metadata-from-file ssh-keys="./id_rsa_formatted.pub"

gcloud compute instances create "$READING_CLIENT-aus" --project=csbench --image-family=debian-11 --zone=australia-southeast1-b --image-project=debian-cloud  --machine-type=e2-medium --create-disk=auto-delete=yes --tags=reading-client,aus
gcloud compute instances add-metadata "$READING_CLIENT-aus" --zone=australia-southeast1-b --metadata-from-file ssh-keys="./id_rsa_formatted.pub"

# add firewall rules for SSH, ICMP, Mongo for all VM.
if gcloud compute firewall-rules list --filter="name~allow-mongo-firewall" | grep -c allow-mongo-firewall==0; then
    gcloud compute firewall-rules create "allow-mongo-firewall" --action=ALLOW --rules=icmp,tcp:22,tcp:27017 --source-ranges=0.0.0.0 --direction=INGRESS
else
    echo "firewall rule already created"
fi

# create replica instances
for i in `seq 1 $NUMBER_OF_REPLICAS`; do
  instance_region=$CLOUDSDK_COMPUTE_ZONE
  tags="replica,eu"
  if [ $i == 1 ]; then
    # create an instance in australia to consider latency deployments.
    instance_region='australia-southeast1-b'
    tags="replica,aus"
  fi

  instance_name="replica-$i-experiment-$run-$instance_region"
  gcloud compute instances create $instance_name --project=csbench --image-family=debian-11 --zone=$instance_region --image-project=debian-cloud  --machine-type=e2-medium --create-disk=auto-delete=yes --tags=$tags
  gcloud compute instances add-metadata $instance_name  --zone=$instance_region --metadata-from-file ssh-keys="./id_rsa_formatted.pub"
done

# create writing client instances
for i in `seq 1 $NUMBER_OF_WR_CLIENTS`; do
  instance_name="writing-client-$i-experiment-$run"
  gcloud compute instances create $instance_name --project=csbench --image-family=debian-11 --zone=$CLOUDSDK_COMPUTE_ZONE --image-project=debian-cloud  --machine-type=e2-medium --create-disk=auto-delete=yes --tags=writing-client
  gcloud compute instances add-metadata $instance_name  --zone=$CLOUDSDK_COMPUTE_ZONE --metadata-from-file ssh-keys="./id_rsa_formatted.pub"
done

echo "Wait for the instances to spin up"
sleep 15

# configure environment
./configure_environment.sh $keypair_name $keypair_file

# configure benchmark clients
./configure_benchmark_clients.sh