# Stonesoup installation

* [Pre-requisite](#pre-requisite)
* [Quicklab](#quicklab)
  * [Cluster setup](#cluster-setup)
  * [Deploy the backend](#deploy-the-backend)
  * [Install the frontend](#install-the-frontend)
* [QuickLab URL and credentials](#quicklab-url-and-credentials)
  * [upi-0.mystone.lab.upshift.rdu2.redhat.com](#upi-0mystonelabupshiftrdu2redhatcom)
  * [upi-0.snowdrop.lab.psi.pnq2.redhat.com](#upi-0snowdroplabpsipnq2redhatcom)
* [CRC](#crc)
  * [Instructions](#instructions)
* [Tips](#tips)

## Pre-requisite

- [Konfig](https://github.com/corneliusweig/konfig) tool able to merge/manage different kube context
- [Kubectx and kubens](https://github.com/ahmetb/kubectx) to switch between the context or namespace

## Quicklab

### Cluster setup

In order to play with Stonesoup, we need an ocp4 cluster with 3 nodes and 3 workers. It can be created
using the application: `https://quicklab.upshift.redhat.com/`.

Select as template: `openshift4upi` and this region `osp_lab-ci-rdu2-a` to create the VMs.
When the VMs are ready, then install the cluster using the button `New bundle` and `openshift4upi`.

**Note**: Select the region `osp_lab-ci-rdu2-a` as it offers more cpu/memory than asian region

To ssh to the VM, copy locally the `quicklab.key`
```bash
wget https://gitlab.cee.redhat.com/cee_ops/quicklab/raw/master/docs/quicklab.key -P config && chmod 600 quicklab.key

QUICK_LAB_HOST=<QUICK_LAB_HOSTNAME>
ssh -i config/quicklab.key -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -o "IdentitiesOnly yes" quicklab@$QUICK_LAB_HOST
```

Next, retrieve the kubeconfig file and merge it locally within your `.kube/config` file

```bash
QUICK_LAB_HOST=<QUICK_LAB_HOSTNAME>
./qlssh.sh $QUICK_LAB_HOST "cat /home/quicklab/oc4/auth/kubeconfig" > config/$QUICK_LAB_HOST.cfg
```

Edit the `config/$QUICK_LAB_HOST.cfg` file to rename the context from `admin` to your quicklab host by example (e.g mystone)
```text
contexts:
- context:
    cluster: mystone
    user: admin
  name: mystone
current-context: mystone
```

Import the context and switch to use it
```bash
konfig import --save config/$QUICK_LAB_HOST.cfg
kubectx mystone
```

### Deploy the backend

Before to execute the command described hereafter, it is first needed to fork this git repository: `https://github.com/redhat-appstudio/infra-deployments/`
within your `GIT_HUB_ORG`. This forked project will be used by argocd to sync the resources to be installed and the installation script will create/commit a branch top of it !

Git clone locally either the forked project (if you plan to develop) or the parent project: `git clone https://github.com/redhat-appstudio/infra-deployments.git`

Create the NFS Storage Class on ocp4 by executing the following script. This storage class will be used to create the Persistent volumes from PVC requests
automatically:
```bash
cd infra-deployments(-fork)
./hack/quicklab/setup-nfs-quicklab.sh $QUICK_LAB_HOST
```

We can now configure the `preview.env` file (`cp hack/preview-template.env hack/preview.env`) which contains different 
variables needed to by example download images from docker hub, push the build images to a registry,
setup the github org hosting the forked project containing the argocd resources, etc.

The most important keys to configure are:
```text
export MY_GIT_FORK_REMOTE=git@github.com:<GITHUB_ORG>/infra-deployments.git
export MY_GITHUB_TOKEN=<PERSONAL GITHUB TOKEN>

export HAS_DEFAULT_IMAGE_REPOSITORY=quay.io/<QUAY_USER>/<REPOSITORY>
export DOCKER_IO_AUTH=<Format username:access_token>
```

Next, deploy the backend part of stonesoup by executing the following bash script
```bash
./hack/bootstrap-cluster.sh --toolchain --keycloak preview
```

**Warning**: If you use an image repository and that you set the ENV VAR: `HAS_DEFAULT_IMAGE_REPOSITORY`, then 
create a [shared secret](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/build-service#use-sharedsecret-with-tekton-chains)
as such using the docker configuration that you can get from: https://quay.io/organization/<QUAY_USER>?tab=robots.
Do not forget to specify as registry under `auths`: `"quay.io/<QUAY_USER>": {` nd not `"quay.io": {`
```bash
kubectl create secret docker-registry -n build-templates redhat-appstudio-user-workload --from-file=.dockerconfigjson=.config/quay_dockercfg.json
```

Open the ocp & argocd console
```text
open https://console-openshift-console.apps.$QUICK_LAB_DOMAIN
open https://openshift-gitops-server-openshift-gitops.apps.$QUICK_LAB_DOMAIN
```

### Install the frontend

Fork the project https://github.com/jduimovich/standalone-hac.git within a `GIT_HUB_ORG` and clone the project locally
```bash
git clone git@github.com:<GIT_HUB_ORG>/standalone-hac.git standalone-hac-fork
cd standalone-hac-fork
```
Create a branch using as name the <HOST_NAME> where stonesoup is deployed
```bash
git checkout -b $QUICK_LAB_HOST
```
Copy the folder `./hack/no-commit-templates` to `./hack/nocommit`

Download your docker credentials to access the quay registry using this link: https://quay.io/organization/<QUAY_ORG>?tab=robots within the file `./hack/quay-io-auth.json` 

Create now the `./hack/nocommit/my-secret.yml` file using the following kubectl command:
```bash
kubectl create secret docker-registry quay-cloudservices-pull --from-file=.dockerconfigjson=./hack/nocommit/quay-io-auth.json --dry-run=client -o yaml > ./hack/nocommit/my-secret.yml
```

Generate the `FrontendEnvironment` CRD using the script `./hack/update-sso.sh` to configure the dev-sso auth domain, hostname
and commit the change within your branch

**Warning**: Edit manually the generated file `components/hac-boot/environment.yaml` to fix the hostname field and append the VM hostname before the domain !

Git clone the following project `clowder` with the parent folder:
```bash
cd ..
git clone https://github.com/RedHatInsights/clowder.git
```
Git clone the following project `crc-k8s-proxy` with the parent folder:

```bash
git clone https://github.com/jduimovich/crc-k8s-proxy.git
```

Create an `envfile` file from the `./envfile-template-local-cluster` template and set the following 2 parameters `HOSTNAME` and `TOKEN`
```text
KEYCLOAK_URL=http://keycloak-svc.dev-sso.svc:8080/auth/realms/redhat-external
HOSTNAME=computed
PROXYSSL=false
SSL=true
MODE=complex
TOKEN=<OCP_LOGIN_TOKEN>
K8SURL=https://kubernetes.default.svc
```

Customize the `standalone-hac-fork` forked repo to point to your branch and commit the change by running this script `./hack/update-app-revisions`

Replace the hard coded `repoURL` using as git repo `https://github.com/jduimovich/standalone-hac.git` with your forked git repo

Execute now this script to install crowder, crc-k8s-proxy and hac-dev:
```bash
./hack/install.sh
```

## QuickLab URL and credentials

### upi-0.mystone.lab.upshift.rdu2.redhat.com

```text
https://quicklab.upshift.redhat.com/clusters/49460
Username: quicklab
QUICK_LAB_HOST: upi-0.mystone.lab.upshift.rdu2.redhat.com
QUICK_LAB_DOMAIN: mystone.lab.upshift.rdu2.redhat.com

Openshift Kubeconfig Located At:
upi-0.mystone.lab.upshift.rdu2.redhat.com:/home/quicklab/oc4/auth/kubeconfig

Clusterversion Output:
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.12.0    True        False         0s      Cluster version is 4.12.0

OpenShift URL: https://console-openshift-console.apps.mystone.lab.upshift.rdu2.redhat.com

OpenShift Credentials: (username: password)
kubeadmin : 2CvsX-vR4m2-dwkVi-wEbGM

open https://console-openshift-console.apps.mystone.lab.upshift.rdu2.redhat.com
open https://openshift-gitops-server-openshift-gitops.apps.mystone.lab.upshift.rdu2.redhat.com
```

### upi-0.snowdrop.lab.psi.pnq2.redhat.com

```text
https://quicklab.upshift.redhat.com/clusters/49430

Username: quicklab
QUICK_LAB_HOST: upi-0.snowdrop.lab.psi.pnq2.redhat.com

OpenShift URL: https://console-openshift-console.apps.snowdrop.lab.psi.pnq2.redhat.com

OpenShift Credentials: (username: password)
kubeadmin : DCvcE-3BBpx-UTqF3-sAhFq

open https://console-openshift-console.apps.snowdrop.lab.upshift.rdu2.redhat.com
open https://openshift-gitops-server-openshift-gitops.apps.snowdrop.lab.upshift.rdu2.redhat.com
```

## CRC

https://crc.dev/crc/#introducing_gsg
https://redhat-appstudio.github.io/infra-deployments/docs/development/deployment.html

### Instructions

```bash
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

## Tips

```bash
k get pod -o=json | jq '.items[]|select(any( .status.containerStatuses[]; .state.waiting.reason=="ImagePullBackOff"))|.metadata.name'
```
