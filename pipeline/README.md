## How to play with Tekton PipelineAsCode

- Create a kind cluster where you deploy an ingress controller and docker registry
```bash
VM_IP=10.0.76.167
curl -s -L "https://raw.githubusercontent.com/snowdrop/k8s-infra/main/kind/kind.sh" | bash -s install --delete-kind-cluster
```

- Install Tekton client

See documentation: https://pipelinesascode.com/docs/guide/cli/
```bash
wget https://github.com/openshift-pipelines/pipelines-as-code/releases/download/v0.19.1/tkn-pac-0.19.1_Linux-64bit.rpm
sudo rpm -i tkn-pac-0.19.1_Linux-64bit.rpm

brew install openshift-pipelines/pipelines-as-code/tektoncd-pac
```

- Deploy Tekton, Tekton Dashboard
```bash
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml
```
- Create the ingress route to access the Tekton dashboard
```bash
DASHBOARD_URL=tekton-ui.${VM_IP}.nip.io
cat <<EOF | kubectl apply -n tekton-pipelines -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tekton-dashboard
  namespace: tekton-pipelines
spec:
  rules:
  - host: $DASHBOARD_URL
    http:
      paths:
      - pathType: ImplementationSpecific
        backend:
          service:
            name: tekton-dashboard
            port:
              number: 9097
EOF
```
- If you don't use the `tkn-pac` client, you have to install now PipelineAsCode:
```bash
kubectl apply -f https://raw.githubusercontent.com/openshift-pipelines/pipelines-as-code/stable/release.k8s.yaml
```

- Expose a new route to allow to access the PipelineAsCode controller externally
```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  labels:
    pipelines-as-code/route: controller
  name: pipelines-as-code
  namespace: pipelines-as-code
spec:
  ingressClassName: nginx
  rules:
  - host: pac.${VM_IP}.nip.io
    http:
      paths:
      - backend:
          service:
            name: pipelines-as-code-controller
            port:
              number: 8080
        path: /
        pathType: Prefix
EOF
```
- Install gosmee pod and configure it
```bash
SMEE_URL=https://smee.io/pac.${VM_IP}.nip.io
kubectl delete deployment/gosmee-client
cat <<EOF | kubectl apply -f -
kind: Deployment
apiVersion: apps/v1
metadata:
  name: gosmee-client
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gosmee-client
  template:
    metadata:
      labels:
        app: gosmee-client
    spec:
      containers:
        - name: gosmee-client
          image: 'ghcr.io/chmouel/gosmee:main'
          args:
            - client
            - ${SMEE_URL}
            - http://pipelines-as-code-controller.pipelines-as-code.svc.cluster.local:8080
      restartPolicy: Always
EOF
```

## Set up a GitHub App

To forward the GitHub events (commit, PR, etc) to Tekton PipelineAsCode it is needed to create a [GithubApp](https://pipelinesascode.com/docs/install/github_apps/).
That could be done manually as described [here](https://pipelinesascode.com/docs/install/github_apps/#setup-manually) or using the `tkn-pac bootstrap github-app` client
as showed hereafter:

```bash
Example:
SMEE_URL=https://smee.io/pac.${VM_IP}.nip.io (e.g: https://smee.io/pac.10.0.76.167.nip.io)
GITHUB_APP_URL=https://github.com/ch007m/tekton-pac
tkn-pac bootstrap \
  -t github-app \
  --github-application-name "Snowdrop VPN" \
  --github-organization-name "ch007m" \
  --github-application-url https://github.com/ch007m/tekton-pac \
  --route-url ${SMEE_URL} \
  --web-forwarder-url ${SMEE_URL}
```
>**Note**: It is needed to execute this command from a machine where you can access the web server started by tkn-pac as localhost !!

Install the newly created GitHub app within the org and select the repositories from where events will be pulled
```bash
🚀 You can now add your newly created application on your repository by going to this URL:

https://github.com/apps/snowdrop-vpn
```
>**Warning**: If you plan to reuse from another Tekton cluster the `github-application-id`, `github-private-key` and `webhook.secret`, then get the secret populated
and store it under password store
```bash
GITHUB_APP_NAME="snowdrop-vpn"
kubectl get secret -n pipelines-as-code pipelines-as-code-secret -ojson | jq -r '.data."github-application-id" | @base64d' | pass insert -e github/apps/${GITHUB_APP_NAME}/github-application-id
kubectl get secret -n pipelines-as-code pipelines-as-code-secret -ojson | jq -r '.data."github-private-key" | @base64d' | pass insert -m github/apps/${GITHUB_APP_NAME}/github-private-key
kubectl get secret -n pipelines-as-code pipelines-as-code-secret -ojson | jq -r '.data."webhook.secret" | @base64d' | pass insert -e github/apps/${GITHUB_APP_NAME}/webhook.secret
```

To create a secret containing the needed information from password store
```bash
GITHUB_APP_NAME="snowdrop-vpn"
GITHUBAPP_PRIVATE_KEY=$(PASSWORD_STORE_DIR=~/.password-store-work pass show github/apps/${GITHUB_APP_NAME}/github-private-key)
GITHUBAPP_ID=$(PASSWORD_STORE_DIR=~/.password-store-work pass show github/apps/${GITHUB_APP_NAME}/github-application-id | awk 'NR==1{print $1}')
GITHUBAPP_WEBHOOK_SECRET=$(PASSWORD_STORE_DIR=~/.password-store-work pass show github/apps/${GITHUB_APP_NAME}/webhook.secret | awk 'NR==1{print $1}')
#GITHUB_TOKEN=$(PASSWORD_STORE_DIR=~/.password-store-work pass show github/apps/${GITHUB_APP_NAME}/github_token | awk 'NR==1{print $1}')

kubectl delete secret/pipelines-as-code-secret -n pipelines-as-code
kubectl -n pipelines-as-code create secret generic pipelines-as-code-secret \
        --from-literal github-private-key="$(echo $GITHUBAPP_PRIVATE_KEY)" \
        --from-literal github-application-id="$GITHUBAPP_ID" \
        --from-literal webhook.secret="$GITHUBAPP_WEBHOOK_SECRET" #\
        #--from-literal github.token=$GITHUB_TOKEN 
```

>**Note**: It can also be patched to add by the example the github token:
```bash
GITHUB_TOKEN=$(PASSWORD_STORE_DIR=~/.password-store-work pass show github/apps/my-pipeline-as-code/github_token | awk 'NR==1{print $1}')
GITHUB_TOKEN_BASE64=$(echo $GITHUB_TOKEN | base64 | tr -d '\n')
kubectl get secret -n pipelines-as-code pipelines-as-code-secret -o json \
        | jq '.data["github.token"] = "'"$GITHUB_TOKEN_BASE64"'"' \
        | kubectl apply -f - 
```        

## Demo

To test PipelineAsCode, we will have to create a `Repository`
```bash
kubectl create ns quarkus-demo
kubectl delete repositories.pipelinesascode.tekton.dev/quarkus-hello -n quarkus-demo
cat <<EOF | kubectl apply -f -
apiVersion: pipelinesascode.tekton.dev/v1alpha1
kind: Repository
metadata:
  name: quarkus-hello
  namespace: quarkus-demo
spec:
  git_provider:
    secret:
      key: github.token
      name: pipelines-as-code-secret
    webhook_secret:
      key: webhook.secret
      name: pipelines-as-code-secret
  url: ${GITHUB_APP_URL}
EOF
```

and to add a `.tekton` folder containing the PipelineRun to be tested/demo 
```bash
BRANCH_NAME=pac-maven-test
git checkout main
git push -d origin ${BRANCH_NAME}
git branch -D ${BRANCH_NAME}
git checkout -b ${BRANCH_NAME}

mkdir -p .tekton
wget https://raw.githubusercontent.com/ch007m/tekton-pac/main/k8s/pipelinerun-maven.yml -O .tekton/pipelinerun.yaml

git add .tekton
git commit -asm "This is a maven build using Pipeline As Code CI"
git push --set-upstream origin ${BRANCH_NAME}
```

>**Warning**: Give the `ClusterRole` ADMIN to the Quarkus-demo account (= where pipeline runs)
```bash
kubectl create clusterrolebinding admin-sa-default-quarkus-demo --clusterrole=admin --serviceaccount=quarkus-demo:default
```

## Buildpacks build

Scenario to be executed to test the Tekton Buildpack build

```bash
BRANCH_NAME=pac-buildpack-test
git checkout main
git push -d origin ${BRANCH_NAME}
git branch -D ${BRANCH_NAME}
git checkout -b ${BRANCH_NAME}

mkdir -p .tekton
wget https://raw.githubusercontent.com/redhat-buildpacks/tekton-pac-poc/main/k8s/pipelinerun-buildpack.yml -O .tekton/pipelinerun.yaml

git add .tekton
git commit -asm "This is a buildpacks build using TektonCI"
git push --set-upstream origin ${BRANCH_NAME}
```
