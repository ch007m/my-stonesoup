#!/bin/bash
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

COMPONENT=$1

kubectl delete --ignore-not-found -f $SCRIPTDIR/templates/application.yaml
kubectl create -f $SCRIPTDIR/templates/application.yaml
if ! kubectl wait --for=condition=Created application/test-application; then
  echo "Application was not created successfully, check:"
  echo "kubectl get applications test-application -o yaml"
  exit 1
fi

function create-component {
  GIT_URL=$1
  REPO=$(echo $GIT_URL | grep -o '[^/]*$')
  NAME=${REPO%%.git}
  [ -z "$SKIP_OUTPUT_IMAGE" ] && IMAGE=quay.io/ch007m/stonesoup:$NAME
  kubectl delete --ignore-not-found component $NAME
  [ -n "$SKIP_INITIAL_CHECKS" ] && ANNOTATE_SKIP_INITIAL_CHECKS='| (.metadata.annotations.skip-initial-checks="true")'
  yq e "(.metadata.name=\"$NAME\") | (.spec.componentName=\"$NAME\") | (.spec.source.git.url=\"$GIT_URL\") | (.spec.containerImage=\"$IMAGE\") | (.metadata.annotations.pipelinesascode=\"$PIPELINESASCODE\") $ANNOTATE_SKIP_INITIAL_CHECKS" $SCRIPTDIR/templates/component.yaml | kubectl apply -f-
}

echo Git Repo created:
kubectl get application/test-application -o jsonpath='{.status.devfile}' | grep appModelRepository.url | cut -f2- -d':'

if [ -z "$COMPONENT" ]; then
  create-component https://github.com/devfile-samples/devfile-sample-java-springboot-basic
  create-component https://github.com/devfile-samples/devfile-sample-code-with-quarkus
  # create-component https://github.com/devfile-samples/devfile-sample-python-basic
else
  create-component $COMPONENT
fi

kubectl get PipelineRun,TaskRun,application,component

echo "Run this to show running builds: tkn pr list"
echo "To see what it has been created: kubectl get PipelineRun,TaskRun,application,component"
