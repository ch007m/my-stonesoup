#!/usr/bin/env bash

# Get the list of the secrets defined within the Service Account
# Extract for each secret the dockercfg or dockercfgjson file
# Decode using base64 the content of the file

SCRIPTS_DIR="$(cd $(dirname "${BASH_SOURCE}") && pwd)"

SA=${1:-pipeline}

CMD=$(kubectl get sa/$SA -ojson | jq -cr '.secrets[] | .name')

for row in $CMD; do
  printf %"s\n" "-----------------------------------------------"
  echo "Secret: $row"
  data=$(kubectl get secret -n user1-tenant $row -ojson)
  secret_type=$(echo $data | jq -r '.type')
  dockercfg_file_name=$(echo $secret_type | cut -d "/" -f 2)

  case $dockercfg_file_name in
    "dockerconfigjson")
      echo $data | jq -r '.data.".dockerconfigjson"' | base64 -d
      ;;

    "dockercfg")
      echo $data | jq -r '.data.".dockercfg"' | base64 -d
      ;;
    *)
      p "Not found";;
  esac
  printf %"s\n" "-----------------------------------------------"
done