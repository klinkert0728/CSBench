#!/bin/bash
cd "$(dirname "$0")" # Go to the script's directory
declare -a IPS=()
export READING_CLIENT=$1
for i in "${@:2}"; do
  IPS+=($(printf '%s' "$i"))
done

index() {
  [[ "${moCurrent#*.}"  ]] && echo "$((${moCurrent#*.} + 1))"
}

export IPS=$IPS
. ./mo
cat ansible/clients_host_template.yml | mo > clients_hosts.yml