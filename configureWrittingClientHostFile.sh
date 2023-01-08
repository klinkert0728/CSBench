#!/bin/bash
cd "$(dirname "$0")" # Go to the script's directory
export WRITTING_CLIENT=$1

. ./mo
cat ansible/add_writting_host_template.yml | mo > additional_writting_client.yml

ansible-playbook -i additional_writting_client.yml ansible/add_writtingClient.yml --ssh-common-args='-o StrictHostKeyChecking=no'