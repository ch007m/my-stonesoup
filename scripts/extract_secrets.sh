#!/usr/bin/env bash

SCRIPTS_DIR="$(cd $(dirname "${BASH_SOURCE}") && pwd)"

CMD=$(kubectl get sa/pipeline -ojson | jq -cr '.secrets[] | .name')

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