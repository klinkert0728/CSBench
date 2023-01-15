#!/usr/bin/env bash

set -euo pipefail

./configureBenchmarkClientsHostfile.sh

ansible-playbook -i clients_hosts.yml ansible/configureBenchmarkClients.yml --ssh-common-args='-o StrictHostKeyChecking=no'