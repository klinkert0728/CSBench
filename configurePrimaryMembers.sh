#!/bin/bash
cd "$(dirname "$0")" # Go to the script's directory
declare -a IPS=()
export PRIMARY=$1

# Replica ips are passed starting the second position of the parameters, the first one must be always the primary
for i in "${@:2}"; do
  IPS+=($(printf '%s' "$i"))
done

index() {
   [[ "${moCurrent#*.}"  ]] && echo "$((${moCurrent#*.} + 1))"
}

vote() {
    [[ "${moCurrent#*.}" == "0" ]] && echo "1"  || echo "0"
}

priority() {
    [[ "${moCurrent#*.}" == "0" ]] && echo "1"  || echo "0"
}

export IPS=$IPS
. ./mo
cat mongosh/config_template | mo > mongosh/members_config.js

mongosh --host $PRIMARY  --file mongosh/members_config.js --port 27017 