# sunbird-devops

This repository contains the information and references needed to run [Sunbird](http://open-sunbird.org/) in a Production environment. The deployment design and software choices taken have been motivated with a need to run Sunbird in a highly available, reliable and scaleable setup. Higher levels of automation have been favored. The stack is meant to be extensible and parts of it are swappable to suit your deployment environments. Pull Requests are invited to add capability and variety to the deployment choices.

## Table of content

- [Prerequisites](#prerequisites)
- [Installation](#installation)
    - [Developer](#developer)
    - [Production](#production)
- [Deployment architecture](#deployment-architecture)
- [License](#license)

## Prerequisites
This section should expand as open source contributions to support multiple run times increase over time. Presently, the software and reference steps consider the following tech stack:

Required:

- Linux, preferably Ubuntu
- [Docker Swarm Mode](https://docs.docker.com/engine/swarm/)
- [Ansible](https://www.ansible.com/)

Optional:

- A CI server, e.x. [Jenkins](https://jenkins.io/), to build extensions and take future upgrades
- a source control mechanism, e.x. [Git](https://github.com/)

## Installation
### Developer
Head over to specific Frontend or Backend service repos in [Project Sunbird](https://github.com/project-sunbird/) to understand how to run the parts of the stack locally, perhaps on your laptop.

### Production

Please refer to https://github.com/project-sunbird/sunbird-devops/blob/master/Installation.md

## Deployment Architecture
### Infrastructure
Sunbird can be run on VMs on various Cloud providers or bare metal. Cloud Infrastructure automation is work in progress.
### Stable Builds Registry
Sunbird builds are available at a [Image Registry](https://hub.docker.com/u/sunbird/dashboard/). These builds are in the form of a [Dockerfile](https://docs.docker.com/engine/reference/builder/). Stable releases are tagged as ```gold```. Deployment scripts pull the ```gold``` images for production deployment. The ```gold``` images are also versioned to allow for release management and upgrade paths.
### Software Runtime
Most runtimes in Sunbird are containerized as [Docker containers](https://www.docker.com/what-container) for portability, process isolation and standardization.  For container orchestration, this repo contains scripts to run Sunbird on [Docker Swarm](https://docs.docker.com/engine/swarm/). Cloud providers provide container services. In this repo, we are using [ACS-Engine](https://github.com/Azure/acs-engine).
### Logging, Monitoring and Operational dashboards
Sunbird comes with log aggregation and metrics reporting out of the box. For log aggregation, Sunbird is using a combination of [cAdvisor](https://github.com/google/cadvisor), [ELK stack](https://www.elastic.co/webinars/introduction-elk-stack), [Prometheus](https://prometheus.io/) and their plugin ecosystem.
Ops dashboards are built using [Grafana](https://grafana.com/) with some [reference](https://github.com/project-sunbird/sunbird-devops/tree/master/cloud/monitoring/grafana) dashboards.
### Custom builds
Sunbird is extendible. Sunbird can be taken as a base image with custom implementation of public interfaces and rebuilt for deployment. Scripts are available for ramping up of complex deployments with support to run local build promotions and deployments.

## License
The code in this repository is licensed under MIT unless otherwise noted. Please see the [LICENSE](https://github.com/project-sunbird/sunbird-devops/blob/master/LICENSE) file for details.
