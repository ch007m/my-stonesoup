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

## Components

| Name                                                                                                                                                       | Description                                                                                                                                                                                                                       | ArgoCD                                                                                                                         |
|------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| [Application API](https://github.com/redhat-appstudio/application-api)                                                                                     | Definition of the CRDs: Application, Component, etc                                                                                                                                                                               | [application-api](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/application-api)                  |
| RBAC                                                                                                                                                       | Project where RBAC have been defined for the staging/prod clusters, team members, etc                                                                                                                                             | [authentication](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/authentication)                    |
| [Build services](https://github.com/redhat-appstudio/build-service)                                                                                        | Tekton and Pipelines build service composed of different modules: OpenShift Pipelines, Tekton Chains, Tekton Results,<br/>Pipelines as Code, Shared Resources, App Studio Build Service,<br/>HACBS JVM Build Service, PVC Cleaner | [build-service](https://github.com/redhat-appstudio/infra-deployments/blob/main/components/build-service/README.md)            |
| [Build definitions](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/build-templates)                                            | Pipelines and tasks                                                                                                                                                                                                               | [build-templates](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/build-templates)                  |
| [Cluster registration operator ](https://github.com/stolostron/cluster-registration-operator)                                                              | The Cluster Registration operator enables users to register clusters to their AppStudio workspace                                                                                                                                 | [cluster-registration](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/cluster-registration)        |
| [Cluster secret store](https://external-secrets.io/main/provider/hashicorp-vault/)                                                                         | External secrets store cofig for Vault                                                                                                                                                                                            | [cluster-secret-store](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/cluster-secret-store)        |
| [Dev SSO](https://access.redhat.com/documentation/en-us/red_hat_single_sign-on/7.6/html-single/server_installation_and_configuration_guide/index#operator) | Red Hat SSO Operator                                                                                                                                                                                                              | [dev-sso](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/dev-sso)                                  |
| [DORA metrics](https://github.com/redhat-appstudio/dora-metrics)                                                                                           | Prometheus exporter collecting the deployment time/frequency in order to measure the DORA performance                                                                                                                             | [dora-metrics](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/dora-metrics)                        |
| [Enterprise contract ](https://hacbs-contract.github.io/ec/main/index.html)                                                                                | Set of tools for applying and maintaining policies about container builds created by Stonesoup.                                                                                                                                   | [enterprise-contract ](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/enterprise-contract)         |
| [External Secrets Operator](https://github.com/external-secrets/external-secrets)                                                                          | Kubernetes Operator integrating external secret management systems (vault, google, AWS, etc)                                                                                                                                      | [external-secrets-store](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/external-secrets-operator) |
| GitOps repository pruner                                                                                                                                   | Empty ArgoCD component to add the tekton files of the stonesoup repo                                                                                                                                                              | [gitops-repo-pruner](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/gitops-repo-pruner)            |
| [GitOps Service](https://github.com/redhat-appstudio/managed-gitops)                                                                                       | GitOps Service integrated with RedHat AppStudio.                                                                                                                                                                                  | [gitops](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/gitops)                                      |
| [Pact Broker](https://github.com/pact-foundation/pact_broker)                                                                                              | Project aiming for sharing of consumer driven contracts and verification results                                                                                                                                                  | [hac-pact-broker](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/hac-pact-broker)                                   |
| [Hybrid Application Service](https://github.com/redhat-appstudio/application-service)                                                                      | Kubernetes operator to create and manage applications and control the lifecycle of applications. [Internal doc](HAS Architecture: https://docs.google.com/document/d/1axzNOhRBSkly3M2Y32Pxr1MBpBif2ljb-ufj0_aEt74)                | [has](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/has)                                               |
| [Image controller](https://github.com/redhat-appstudio/image-controller)                                                                                   | It helps set up container image repositories for StoneSoup Components                                                                                                                                                             | [image-controller](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/image-controller)                                  |
| [Integration](https://github.com/redhat-appstudio/integration-service)                                                                                     | Kubernetes operator to control the integration and testing of HACBS-managed Application Component builds in Red Hat AppStudio                                                                                                     | [integration](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/integration)                                       |
| [Internal services](https://github.com/hacbs-release/internal-services-resources)                                                                          | Kubernetes operator to control the integration and testing of HACBS-managed Application Component builds in Red Hat AppStudio                                                                                                     | [internal-services](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/internal-services)                                 |
| [JVM Build Service]( https://github.com/redhat-appstudio/jvm-build-service/)                                                                               | Additional services used part of the tekton pipleine build to scan images, generate SBOM, tc                                                                                                                                      | [jvm-build-service](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/jvm-build-service)                                 |
| Monitoring                                                                                                                                                 | Metrics exporter servicefor prometheus                                                                                                                                                                                            | [monitoring](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/monitoring)                                        |
| [Pipelines service](https://github.com/openshift-pipelines)                                                                                                | Tekton pipelines service                                                                                                                                                                                                          | [pipeline-service](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/pipeline-service)                                  |
| [Quality dashboard](https://github.com/redhat-appstudio/quality-dashboard)                                                                                 | Collect the status of AppStudio services: bild status, git repo, code coverage, etc                                                                                                                                               | [quality-dashboard](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/quality-dashboard)                                 |
| [Release](https://github.com/redhat-appstudio/release-service)                                                                                             | Kubernetes operator to control the life cycle of HACBS-managed releases in the context of AppStudio.                                                                                                                              | [release](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/release)                                           |
| [Shared resources](https://github.com/openshift/csi-driver-shared-resource)                                                                                | Service which allows to share Secrets/configMaps accross namespace using ContainerStoragDriver (CSI)                                                                                                                              | [shared-resources](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/shared-resources)                                  |
| [SPI vault](https://github.com/redhat-appstudio/service-provider-integration-operator/blob/main/docs/ADMIN.md#vault)                                       | Kubernetes controller/operator that manages SPI ntegration with vault                                                                                                                                                             | [spi-vault](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/spi-vault)                                         |
| [SPI](https://github.com/redhat-appstudio/service-provider-integration-operator/)                                                                          | Kubernetes controller/operator that manages SPI ntegration                                                                                                                                                                        | [spi](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/spi)                                               |
| [Spray Proxy](https://github.com/redhat-appstudio/sprayproxy)                                                                                              | Reverse proxy to broadcast to multiple backends                                                                                                                                                                                   | [sprayproxy](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/sprayproxy)                                        |
| Tekton CI                                                                                                                                                  | Project defining the repositories managed by PaC using the github repo and used internally                                                                                                                                        | [tekton-ci](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/tekton-ci)                                         |

Ticket: https://github.com/redhat-appstudio/book/issues/55

## Installation instructions

- Installation github repo: https://github.com/redhat-appstudio/infra-deployments
- Development and installation documentation: https://redhat-appstudio.github.io/infra-deployments/docs/introduction/about.html
- Architecture book: https://redhat-appstudio.github.io/book/
- Adding a component: https://redhat-appstudio.github.io/infra-deployments/docs/deployment/extending-the-service.html
