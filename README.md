# Zammad Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/zammad)](https://artifacthub.io/packages/helm/zammad/zammad)
[![Release downloads](https://img.shields.io/github/downloads/zammad/zammad-helm/total.svg)](https://github.com/zammad/zammad-helm/releases)
[![Release Charts](https://github.com/zammad/zammad-helm/workflows/Release%20Charts/badge.svg)](https://github.com/zammad/zammad-helm/commits/main)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://github.com/zammad/zammad-helm/blob/main/LICENSE)

A [Helm](https://helm.sh) chart to install [Zammad](https://zammad.org) on [Kubernetes](https://kubernetes.io)

The chart is published as an OCI artifact to `oci://ghcr.io/zammad/charts/zammad`:

```console
helm upgrade --install zammad oci://ghcr.io/zammad/charts/zammad
```

Please see [zammad/README.md](zammad/README.md) for detailed information & instructions.

**Note:** The classic Helm repository at `https://zammad.github.io/zammad-helm` is no longer updated.
Its last chart version is 20.0.2. Please switch to the OCI registry.

## Sources

- [Helm chart sources](https://github.com/zammad/zammad-helm)
- [Helm chart OCI registry](https://github.com/zammad/zammad-helm/pkgs/container/charts%2Fzammad)
- [Helm releases](https://github.com/zammad/zammad-helm/releases)

## Contributing

Please see our [contributing guidelines](https://github.com/zammad/zammad-helm/blob/main/CONTRIBUTING.md).
