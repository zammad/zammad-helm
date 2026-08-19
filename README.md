# Zammad Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/zammad)](https://artifacthub.io/packages/helm/zammad/zammad)
[![Release downloads](https://img.shields.io/github/downloads/zammad/zammad-helm/total.svg)](https://github.com/zammad/zammad-helm/releases)
[![Release Charts](https://github.com/zammad/zammad-helm/workflows/Release%20Charts/badge.svg)](https://github.com/zammad/zammad-helm/commits/main)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://github.com/zammad/zammad-helm/blob/main/LICENSE)

A [Helm](https://helm.sh) chart to install [Zammad](https://zammad.org) — a web-based, open-source
helpdesk and customer support platform — on [Kubernetes](https://kubernetes.io). The chart deploys the
Zammad services (Nginx, Rails, scheduler, and websocket) along with their dependencies: PostgreSQL,
Redis, and Memcached, plus optional bundled Elasticsearch and MinIO.

For detailed information & instructions, including prerequisites (e.g. the ECK operator when using the bundled Elasticsearch), see [zammad/README.md](zammad/README.md).

## Sources

* [Helm chart sources](https://github.com/zammad/zammad-helm)
* [Helm repository source](https://github.com/zammad/zammad-helm/tree/gh-pages)
* [Helm releases](https://github.com/zammad/zammad-helm/releases)

## Contributing

Please see our [contributing guidelines](https://github.com/zammad/zammad-helm/blob/main/CONTRIBUTING.md).
