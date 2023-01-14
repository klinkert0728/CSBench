#!/bin/bash
cd "$(dirname "$0")" # Go to the script's directory
declare -a IPS=()
export READING_CLIENT_EU=$1
export READING_CLIENT_AUS=$2

for i in "${@:3}"; do
  IPS+=($(printf '%s' "$i"))
done

index() {
  [[ "${moCurrent#*.}"  ]] && echo "$((${moCurrent#*.} + 1))"
}

export IPS=$IPS
. ./mo
cat ansible/clients_host_template.yml | mo > clients_hosts.yml