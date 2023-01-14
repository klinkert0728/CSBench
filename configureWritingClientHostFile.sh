#!/bin/bash
cd "$(dirname "$0")" # Go to the script's directory
export WRITING_CLIENT=$1

. ./mo
cat ansible/add_writing_host_template.yml | mo > additional_writing_client.yml

ansible-playbook -i additional_writting_client.yml ansible/add_writingClient.yml --ssh-common-args='-o StrictHostKeyChecking=no'