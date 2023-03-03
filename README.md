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

| Name                                                                                                                                                       | Description                                                                                                                                                                                                                       | ArgoCD                                                                                                                         |
|------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| [Application API](https://github.com/redhat-appstudio/application-api)                                                                                     | Definition of the CRDs: applicatin, component                                                                                                                                                                                     | [application-api](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/application-api)                  |
| ?                                                                                                                                                          | ?                                                                                                                                                                                                                                 | [authentication](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/authentication)                    |
| [Build services](https://github.com/redhat-appstudio/build-service)                                                                                        | Tekton and Pipelines build service composed of different modules: OpenShift Pipelines, Tekton Chains, Tekton Results,<br/>Pipelines as Code, Shared Resources, App Studio Build Service,<br/>HACBS JVM Build Service, PVC Cleaner | [build-service](https://github.com/redhat-appstudio/infra-deployments/blob/main/components/build-service/README.md)            |
| [Build definitions](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/build-templates)                                            | Pipelines and tasks                                                                                                                                                                                                               | [build-templates](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/build-templates)                  |
| [Cluster registration operator ](https://github.com/stolostron/cluster-registration-operator)                                                              | The Cluster Registration operator enables users to register clusters to their AppStudio workspace                                                                                                                                 | [cluster-registration](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/cluster-registration)        |
| [Cluster secret store](https://external-secrets.io/main/provider/hashicorp-vault/)                                                                         | External secrets store cofig for Vault                                                                                                                                                                                            | [cluster-secret-store](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/cluster-secret-store)        |
| [Dev SSO](https://access.redhat.com/documentation/en-us/red_hat_single_sign-on/7.6/html-single/server_installation_and_configuration_guide/index#operator) | Red Hat SSO Operator                                                                                                                                                                                                              | [dev-sso](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/dev-sso)                                  |
| [dora metrics](https://github.com/redhat-appstudio/dora-metrics)                                                                                           |                                                                                                                                                                                                                                   | [dora-metrics](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/dora-metrics)                        |
| [Enterprise contract ](https://hacbs-contract.github.io/ec/main/index.html)                                                                                | Set of tools for applying and maintaining policies about container builds created by Stonesoup.                                                                                                                                   | [enterprise-contract ](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/enterprise-contract)         |
| [External Secrets Operator](https://github.com/external-secrets/external-secrets)                                                                          | Kubernetes Operator integrating external secret management systems (vault, google, AWS, etc)                                                                                                                                      | [external-secrets-store](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/external-secrets-operator) |
| GitOps repository pruner                                                                                                                                   |x| [gitops-repo-pruner](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/gitops-repo-pruner)            |
| GitOps                                                                                                                                                     |x| [gitops](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/gitops)                                      |
| HAC pact                                                                                                                                                   |x| [hac-pact-broker](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/hac-pact-broker)                                   |
| HAS                                                                                                                                                        |x| [has](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/has)                                               |
| Image controller                                                                                                                                           |x| [image-controller](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/image-controller)                                  |
| Integration                                                                                                                                                |x| [integration](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/integration)                                       |
| Internal services                                                                                                                                          |x| [internal-services](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/internal-services)                                 |
| JVM Build Service                                                                                                                                          |x| [jvm-build-service](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/jvm-build-service)                                 |
| Monitoring                                                                                                                                                 |x| [monitoring](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/monitoring)                                        |
| Pipelines service                                                                                                                                          |x| [pipeline-service](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/pipeline-service)                                  |
| Quality dashboard                                                                                                                                          |x| [quality-dashboard](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/quality-dashboard)                                 |
| Release                                                                                                                                                    |x| [release](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/release)                                           |
| Sahred resources                                                                                                                                           |x| [shared-resources](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/shared-resources)                                  |
| SPI vault                                                                                                                                                  |x| [spi-vault](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/spi-vault)                                         |
| SPI                                                                                                                                                        |x| [spi](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/spi)                                               |
| Spray Proxy                                                                                                                                                |x| [sprayproxy](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/sprayproxy)                                        |
| Tekton CI                                                                                                                                                  |x| [tekton-ci](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/tekton-ci)                                         |

## Installation instructions

- Installation github repo: https://github.com/redhat-appstudio/infra-deployments
- Development and installation documentation: https://redhat-appstudio.github.io/infra-deployments/docs/introduction/about.html
- Architecture book: https://redhat-appstudio.github.io/book/
- Adding a component: https://redhat-appstudio.github.io/infra-deployments/docs/deployment/extending-the-service.html
