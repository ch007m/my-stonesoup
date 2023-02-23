#!/usr/bin/env bash

SCRIPTS_DIR="$(cd $(dirname "${BASH_SOURCE}") && pwd)"

source ${SCRIPTS_DIR}/common.sh
source ${SCRIPTS_DIR}/play.sh

# Parameters to play the demo
TYPE_SPEED="100"
NO_WAIT=true

CMD=$(kubectl get sa/pipeline -ojson | jq -cr '.secrets[] | .name')

for row in $CMD; do
  p "Secret: $row"
  kubectl get secret -n user1-tenant $row -ojson | jq -r '.data.".dockerconfigjson"' | base64 -d
  p "-----------------------------------------------"
done