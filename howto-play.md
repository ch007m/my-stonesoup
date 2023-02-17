## Quicklab

In order to play with Stonesoup, we need an ocp4 cluster with 3 nodes and 3 workers. It can be created
using the application: `https://quicklab.upshift.redhat.com/`.

Select as template: `openshift4upi` and this region `osp_lab-ci-rdu2-a` to create the VMs.
When the VMs are ready, then install the cluster using the button `New bundle` and ``

**Note**: Select the region `osp_lab-ci-rdu2-a` as it offers more cpu/memory than asian region

To ssh to the VM, copy locally the `quicklab.key`
```bash
wget https://gitlab.cee.redhat.com/cee_ops/quicklab/raw/master/docs/quicklab.key && chmod 600 quicklab.key

QUICK_LAB_HOST=<QUICK_LAB_HOSTNAME>
ssh -i quicklab.key -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -o "IdentitiesOnly yes" quicklab@$QUICK_LAB_HOST
```

Next, retrieve the kubeconfig file and merge it locally within your `.kube/config` file

```bash
QUICK_LAB_HOST=upi-0.snowdrop.lab.psi.pnq2.redhat.com
./qlssh.sh $QUICK_LAB_HOST "cat /home/quicklab/oc4/auth/kubeconfig" > ql_ocp4.cfg

konfig merge --save ql_ocp4.cfg
kubecontext admin
```

Clone locally the fork of the git repository: `https://github.com/redhat-appstudio/infra-deployments/`

Create the NFS Storage Class on ocp4 by executing the following script. This storage class will be used to create the Persistent volumes from PVC requests
automatically:
```bash
cd infra-deployments-fork
./hack/quicklab/setup-nfs-quicklab.sh $QUICK_LAB_HOST
```

We can now configure the `preview.env` file (`cp hack/preview-template.env hack/preview.env`) which contains different 
variables needed to by example download images from docker hub, push the build images to a registry,
setup the github org hosting the forked projects containing the argocd resources, etc.

The most important keys are:
```text
export MY_GIT_FORK_REMOTE=git@github.com:<GITHUB_ORG>/infra-deployments.git
export MY_GITHUB_TOKEN=<PERSONAL GITHUB TOKEN>

export HAS_DEFAULT_IMAGE_REPOSITORY=quay.io/<QUAY_USER>/<REPOSITORY>
export DOCKER_IO_AUTH=<Format username:access_token>
```

We can now deploy the backend part of stonesoup by executing the following bash script
```bash
./hack/bootstrap-cluster.sh --toolchain --keycloak preview
```

**Warning**: If you use an image repository and the env ar `HAS_DEFAULT_IMAGE_REPOSITORY` has been defined, 
create then a shared secret as such: `kubectl create secret docker-registry -n build-templates redhat-appstudio-user-workload --from-file=.dockerconfigjson=./quay_dockercfg.json"`

Open the ocp & argocd console
```
open https://console-openshift-console.apps.$QUICK_LAB_DOMAIN
open https://openshift-gitops-server-openshift-gitops.apps.$QUICK_LAB_DOMAIN
```

### Remotely
```
cd /Users/cmoullia/code/redhat-appstudio
QUICK_LAB_HOST=upi-0.snowdrop.lab.upshift.rdu2.redhat.com
ssh -i quicklab.key -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -o "IdentitiesOnly=yes" quicklab@$QUICK_LAB_HOST
sudo yum install wget git
sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo yum install gh

cat <<EOF > mytoken.txt
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
EOF
gh auth login --with-token < mytoken.txt

git config --global user.name "Charles Moulliard"
git config --global user.email cmoulliard@redhat.com

ssh-keygen -t ed25519 -C "cmoulliard@redhat.com"
gh ssh-key delete -t stonesoup
gh ssh-key add ~/.ssh/id_ed25519.pub -t stonesoup

mkdir stonesoup && cd stonesoup
wget https://github.com/mikefarah/yq/releases/download/v4.30.7/yq_linux_386.tar.gz
tar -vxf yq_linux_386.tar.gz && sudo cp ./yq_linux_386 /usr/local/bin/yq

git clone git@github.com:ch007m/infra-deployments.git && cd infra-deployments
cat <<EOF > hack/preview.env
# Required
## Git remote repo name where is your fork where to push the changes.
## List of remotes -> git remote -v
## Example value: origin
export MY_GIT_FORK_REMOTE=git@github.com:ch007m/infra-deployments.git

## HAS enable github integration
### Your GITHUB organization where to manage repositories by HAS
export MY_GITHUB_ORG=ch007m
### Personal API token with repo and delete_repo permission
export MY_GITHUB_TOKEN=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

# Optional

## HAS enable github integration
### Override default Application service "image push" repository
export HAS_DEFAULT_IMAGE_REPOSITORY=
### Override Application service image
export HAS_IMAGE_REPO=
export HAS_IMAGE_TAG=
export HAS_PR_OWNER=
export HAS_PR_SHA=
### Override Build service image
export BUILD_SERVICE_IMAGE_REPO=
export BUILD_SERVICE_IMAGE_TAG=
export BUILD_SERVICE_PR_OWNER=
export BUILD_SERVICE_PR_SHA=
### Override JVM Build service image
export JVM_BUILD_SERVICE_IMAGE_REPO=
export JVM_BUILD_SERVICE_IMAGE_TAG=
export JVM_BUILD_SERVICE_PR_OWNER=
export JVM_BUILD_SERVICE_PR_SHA=
export JVM_BUILD_SERVICE_CACHE_IMAGE=
export JVM_BUILD_SERVICE_REQPROCESSOR_IMAGE=
### Override the default Tekton bundle
export DEFAULT_BUILD_BUNDLE=

## Integration service
### Change of the image
export INTEGRATION_IMAGE_REPO=
export INTEGRATION_IMAGE_TAG=
export INTEGRATION_RESOURCES=

## Release service
### Change of the image
export RELEASE_IMAGE_REPO=
export RELEASE_IMAGE_TAG=
export RELEASE_RESOURCES=

## SPI integration
### Based on https://github.com/redhat-appstudio/service-provider-integration-operator#configuration
export SHARED_SECRET= # Random string
export SPI_TYPE= # GitHub
export SPI_CLIENT_ID=
export SPI_CLIENT_SECRET=
### Change of the image
# Operator
export SPI_OPERATOR_IMAGE_REPO=
export SPI_OPERATOR_IMAGE_TAG=
# Oauth
export SPI_OAUTH_IMAGE_REPO=
export SPI_OAUTH_IMAGE_TAG=
### The API server SPI should use to perform cluster requests. This should be the same as the API server
### used by HAC.
export SPI_API_SERVER=

## Application management
### Deploy only listed applications
export DEPLOY_ONLY=""

## Docker.io authenticated - to avoid pull limits
### Format username:access_token, eg. mkovarik:59028532-a374-11ec-989b-98fa9b70b53f
export DOCKER_IO_AUTH="cmoulliard:dckr_pat_PkR5WbHkNxlthe0QyOeeFRwzH4A"


## Pipelines as Code integration
### Instructions for PaC GitHub application creation - https://pipelinesascode.com/docs/install/github_apps/#setup
### Webhook url, webhook secret is managed by preview.sh
### pipelines-as-code-secret is created by preview.sh
export PAC_GITHUB_APP_PRIVATE_KEY= # Base64 encoded private key of the GitHub APP
export PAC_GITHUB_APP_ID= # Application ID

# GitHub webhook integration (alternative to the GitHub PaC application)
# See https://pipelinesascode.com/docs/install/github_webhook/#setup-git-repository for the required token permissions
# MY_GITHUB_TOKEN is used as fallback
export PAC_GITHUB_TOKEN=

# GitLab webhook integration
# See https://pipelinesascode.com/docs/install/gitlab/#create-gitlab-personal-access-token for the required token permissions
export PAC_GITLAB_TOKEN=
EOF

./hack/quicklab/setup-nfs-quicklab.sh $QUICK_LAB_HOST
./hack/bootstrap-cluster.sh preview
```

## QuickLab URL and credentials

### upi-0.mystone.lab.upshift.rdu2.redhat.com

https://quicklab.upshift.redhat.com/clusters/49460
Username: quicklab
QUICK_LAB_HOST: upi-0.mystone.lab.upshift.rdu2.redhat.com


### upi-0.snowdrop.lab.psi.pnq2.redhat.com

https://quicklab.upshift.redhat.com/clusters/49430

Username: quicklab
QUICK_LAB_HOST: upi-0.snowdrop.lab.psi.pnq2.redhat.com

OpenShift URL: https://console-openshift-console.apps.snowdrop.lab.psi.pnq2.redhat.com

OpenShift Credentials: (username: password)
kubeadmin : DCvcE-3BBpx-UTqF3-sAhFq

open https://console-openshift-console.apps.snowdrop.lab.upshift.rdu2.redhat.com
open https://openshift-gitops-server-openshift-gitops.apps.snowdrop.lab.upshift.rdu2.redhat.com

### Tips

```bash
k get pod -o=json | jq '.items[]|select(any( .status.containerStatuses[]; .state.waiting.reason=="ImagePullBackOff"))|.metadata.name'
```



## CRC

https://crc.dev/crc/#introducing_gsg
https://redhat-appstudio.github.io/infra-deployments/docs/development/deployment.html

### Instructions
```
mkdir stonesoup && cd stonesoup
wget https://developers.redhat.com/content-gateway/rest/mirror/pub/openshift-v4/clients/crc/latest/crc-linux-amd64.tar.xz
tar -vxf crc-linux-amd64.tar.xz

mkdir -p ~/.crc/bin
cp crc-linux-2.13.1-amd64/crc ~/.crc/bin

export PATH=$PATH:$HOME/.crc/bin
echo 'export PATH=$PATH:$HOME/.crc/bin' >> ~/.bashrc

cat <<EOF > secret.json
{"auths":{"cloud.openshift.com":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K2Ntb3VsbGlhMWpqZjBqbWVoa2JhMW1sY3ZoNHR0d2F0ZW1iOlYxOU5YQ1BXWjJVSDkxMjFPN0JTUkxCWThSN0owS0lPMjQwNjdRNEVEOUg3OUNPQzZZWlNBNzlCQzg4R0dRQ0s=","email":"cmoullia@redhat.com"},"quay.io":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K2Ntb3VsbGlhMWpqZjBqbWVoa2JhMW1sY3ZoNHR0d2F0ZW1iOlYxOU5YQ1BXWjJVSDkxMjFPN0JTUkxCWThSN0owS0lPMjQwNjdRNEVEOUg3OUNPQzZZWlNBNzlCQzg4R0dRQ0s=","email":"cmoullia@redhat.com"},"registry.connect.redhat.com":{"auth":"NTA5ODY1ODh8dWhjLTFKSmYwSm1FSGtCYTFtbEN2SDRUdFdBVEVtYjpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSTJaVGhpTnpoak5HRmxabUkwTldWbU9UVmxNakpsTXpVd09UaGxaVEF6TXlKOS5zY3dGai1hc0RFYmNMUHNzWHgwdmNhUTZybEc4WVpLSW04Y0FWUFI0ZVpzVWtva2FXNVBIYWppOU9USi1mejFDWF84LXhjWnlMQmxLY0lqdVJheGVDTGowQUR3LXh6cHdibms0T3lmbHJ0eGVxVDM1TUZpMGtKOHZDTGNmOFFxdDAyTFBrSzhfYVRYVXd3cTJ1eEl5U3dHTWswN0MwSEgwLTRtTlpPWHhsRmpwdnlUeGRUSEJYM0wzQ19LbTM2MGhlMlBUdHBrMm13REZ6TkhpUG9RdjA5MXpSVXZnMzFFemNkeE0wYnh3Mkt3c1ZsT3RncEdmODhVYk1yMU1lNVQ2SkVYMkFTeTRQSXdQSlg3RVNSdVp4YlBnX0VHUUZoNUY1akZlU1hWUVJMTHVpWDgzT2lzclFmSFo4TkhkLXdnOXJ5eVQxbXlybWhVRndNTlViX2xxb3NobEtPd1N4YXlKaTFhLWhVQmtPVmt0QXhCbGRZdUJsV2FnSzctcl8tT1hoWm5QSFNwYnJPSG9PT21MaHl0VEh4OElWTTlJZ2c1cjYyTFFIUnJ2NWR6bkJZbEhqOGo2OXZYbkFiMFZKVldJOFdlTlBlQkRvWlVnSkhmUnRLblBqUlpLM09qZkp4c1ZmSHZCMFpvMGZHTFBLSXhCV1F1WVFWeEJVeFFzY3R1QmNrOW5tX0E3S19pWlNRMnAwdHEzR0Z4YWFab041a2xxOFowQzNOcjVMRWJ2dlozWXdDTWp5YzFaSjB0RHRkWGhwR1JwbUVFZER3VmtWc1hJZHpXT3Y2T0gycFBQZEhlX2tmN1FlVE5xeU9wR3FQSzd2aXlqX1B3MjBqdXN0OTlEUkJtVlotU3drV21tb2Iyc1VNRGFtWl83Y1hwQzVqTzNncUtvMFdBVmFHbw==","email":"cmoullia@redhat.com"},"registry.redhat.io":{"auth":"NTA5ODY1ODh8dWhjLTFKSmYwSm1FSGtCYTFtbEN2SDRUdFdBVEVtYjpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSTJaVGhpTnpoak5HRmxabUkwTldWbU9UVmxNakpsTXpVd09UaGxaVEF6TXlKOS5zY3dGai1hc0RFYmNMUHNzWHgwdmNhUTZybEc4WVpLSW04Y0FWUFI0ZVpzVWtva2FXNVBIYWppOU9USi1mejFDWF84LXhjWnlMQmxLY0lqdVJheGVDTGowQUR3LXh6cHdibms0T3lmbHJ0eGVxVDM1TUZpMGtKOHZDTGNmOFFxdDAyTFBrSzhfYVRYVXd3cTJ1eEl5U3dHTWswN0MwSEgwLTRtTlpPWHhsRmpwdnlUeGRUSEJYM0wzQ19LbTM2MGhlMlBUdHBrMm13REZ6TkhpUG9RdjA5MXpSVXZnMzFFemNkeE0wYnh3Mkt3c1ZsT3RncEdmODhVYk1yMU1lNVQ2SkVYMkFTeTRQSXdQSlg3RVNSdVp4YlBnX0VHUUZoNUY1akZlU1hWUVJMTHVpWDgzT2lzclFmSFo4TkhkLXdnOXJ5eVQxbXlybWhVRndNTlViX2xxb3NobEtPd1N4YXlKaTFhLWhVQmtPVmt0QXhCbGRZdUJsV2FnSzctcl8tT1hoWm5QSFNwYnJPSG9PT21MaHl0VEh4OElWTTlJZ2c1cjYyTFFIUnJ2NWR6bkJZbEhqOGo2OXZYbkFiMFZKVldJOFdlTlBlQkRvWlVnSkhmUnRLblBqUlpLM09qZkp4c1ZmSHZCMFpvMGZHTFBLSXhCV1F1WVFWeEJVeFFzY3R1QmNrOW5tX0E3S19pWlNRMnAwdHEzR0Z4YWFab041a2xxOFowQzNOcjVMRWJ2dlozWXdDTWp5YzFaSjB0RHRkWGhwR1JwbUVFZER3VmtWc1hJZHpXT3Y2T0gycFBQZEhlX2tmN1FlVE5xeU9wR3FQSzd2aXlqX1B3MjBqdXN0OTlEUkJtVlotU3drV21tb2Iyc1VNRGFtWl83Y1hwQzVqTzNncUtvMFdBVmFHbw==","email":"cmoullia@redhat.com"}}}
EOF


wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz
tar -vxf openshift-client-linux.tar.gz
sudo cp oc /usr/local/bin

git clone https://github.com/redhat-appstudio/infra-deployments.git && cd infra-deployments/
./hack/setup/install-pre-req.sh

sudo dnf install haproxy /usr/sbin/semanage
sudo systemctl enable --now firewalld
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --add-service=kube-apiserver --permanent
sudo firewall-cmd --reload
sudo semanage port -a -t http_port_t -p tcp 6443
sudo cp /etc/haproxy/haproxy.cfg{,.bak}

export CRC_IP=$(crc ip)
sudo tee /etc/haproxy/haproxy.cfg &>/dev/null <<EOF
global
log /dev/log local0

defaults
balance roundrobin
log global
maxconn 100
mode tcp
timeout connect 5s
timeout client 500s
timeout server 500s

listen apps
bind 0.0.0.0:80
server crcvm $CRC_IP:80 check

listen apps_ssl
bind 0.0.0.0:443
server crcvm $CRC_IP:443 check

listen api
bind 0.0.0.0:6443
server crcvm $CRC_IP:6443 check
EOF
sudo systemctl restart haproxy

./hack/setup/prepare-crc.sh --delete-cluster --memory 40000
oc patch clusterversion/version --type merge -p  '{"spec":{"capabilities":{"additionalEnabledCapabilities":["openshift-samples","marketplace","Console","Storage"]}}}'
crc stop
crc config set consent-telemetry no
crc config set disk-size 512
crc start
```