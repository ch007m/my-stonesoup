# Stonesoup

## Scope/MVP

The scope of Stonesoup is defined [here](https://docs.google.com/document/d/1elg__pZXTXu2U5SJL1RbWBVpy76cXov4LQsfzjsUasA).
The chapters 1 to 4 will be delivered at Summit 2023

## General information

- Onboarding (chat, ...): https://docs.google.com/document/d/11TcnrLDJjFUgsMtKwC8vh9AC3APCMdQ7XHB2nLJqkR8
- Accessing Staging environment (UI, oc): https://docs.google.com/document/d/1hFvQDH1H6MGNqTGfcZpyl2h8OIaynP8sokZohCS0Su0/edit#heading=h.olhho0rpp8t5
- Kanban features board: https://issues.redhat.com/secure/RapidBoard.jspa?rapidView=13974
- Teams: https://docs.google.com/spreadsheets/d/1meAQQVmBRUmBYw97JV4eszv4_ugJxbER0WPSdj4y-Ew
- Bug triage process: https://docs.google.com/document/d/1yD3ZzvkqFUh6BulTFrkqynOI-O73e9PQpGHb4OPVzBU/

Less important but could be nevertheless helpful

- User journeys: https://docs.google.com/document/d/14vBqCBA5Y_HYNMuE_krQzBsE97OIR5MIovYgvR5-7Zs
- Architecture deep dive: https://docs.google.com/document/d/1hT1EV-z4iKCDji6em8QRfUzZtVhGSjUswk_eh1odoc4/

## Components & Architecture

- HAS Architecture: https://docs.google.com/document/d/1axzNOhRBSkly3M2Y32Pxr1MBpBif2ljb-ufj0_aEt74
  Component & project: https://github.com/redhat-appstudio/application-service

Application API: https://github.com/redhat-appstudio/application-api
Build Service: https://github.com/redhat-appstudio/build-service
Build definition: https://github.com/redhat-appstudio/build-definitions
JWS Build Service: https://github.com/redhat-appstudio/jvm-build-service/

See: https://github.com/redhat-appstudio/book/issues/55

- GitOps Service
- Pipeline Service
- Build Service
- Workspace and Terminal Service
- Service Provider Integration
- Hybrid Application Service
- Enterprise Contract
- Java Rebuilds Service
- Release Service
- Integration Service

## Installation instructions

- Installation github repo: https://github.com/redhat-appstudio/infra-deployments
- Development and installation documentation: https://redhat-appstudio.github.io/infra-deployments/docs/introduction/about.html
- Architecture book: https://redhat-appstudio.github.io/book/
- Adding a component: https://redhat-appstudio.github.io/infra-deployments/docs/deployment/extending-the-service.html

## Demo

### Prerequisite

To test a GitHub project using our own GitHub org (e.g. ch007m), it is needed to install the following application http://github.com/apps/appstudio-staging-ci able 
to create PR from stonesoup if you want to install within your demo projects tekton pipelines, devfiles, etc

To access the cluster and to avoid to re-issue a token, use [kubelogin](https://github.com/int128/kubelogin), OIDC and the following [Kubecfg]() to 
access the stonesoup [beta cluster](https://console.redhat.com/beta/hac/stonesoup).

**NOTE**: How to Login & access stonesoup cluster: https://docs.google.com/document/d/1hFvQDH1H6MGNqTGfcZpyl2h8OIaynP8sokZohCS0Su0/edit#heading=h.ba1wkdpj2vdq

### Samples

- Repository where ArgoCD resources are stored: https://github.com/redhat-appstudio-appdata/
- Collection of demos to play with Stonesoup: https://github.com/jduimovich/appstudio-e2e-demos

### Automate tests

in infra-deployments there is https://github.com/redhat-appstudio/infra-deployments/tree/main/hack/build build-via-appstudio.sh creates basic CR of app and component from templates folder (edited)

If you are feeling adventurous you can dig into our e2e-demo suite and see the resources we create there: https://github.com/redhat-appstudio/e2e-tests/blob/main/tests/e2e-demos/e2e-demo.go
The suite does the "create application and other necessary resources, wait for build, deploy & check" cycle and is parameterized by applicaitons&components from this yaml

### Setup a new pipeline

https://redhat-internal.slack.com/archives/C04GVLR0155/p1674836372361809

- Start with a PoC in your own repo by modifying the .tekton/pipelinerun definition. Share a demo in the stonesoup weekly meeting (every thursday).
- After that, we may want to get a task for it defined in https://github.com/redhat-appstudio/build-definitions/tree/main/tasks/ and a separate pipeline definition to refer to that task.

**NOTE**: No UI support currently planned for selecting different pipeline types, but that will have to come.

**NOTE**: Even if your pipelinerun uses a new inline task or refers to a new task that we add to build-definitions,
it won't necessarily be trusted by the enterprise contract (example: https://github.com/hacbs-contract/ec-policies/pull/291/files ).
We'll need to evaluate if the new method meets criteria to support the requirements that the policy represents.
