#!/bin/bash
#
# use kubeconform to validate helm generated kubernetes manifest
#

set -o errexit
set -o pipefail

CHART_DIRS="zammad/"

# install kubeconform
curl --silent --show-error --fail --location --output /tmp/kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/download/"${KUBECONFORM_VERSION}"/kubeconform-linux-amd64.tar.gz
sudo tar -C /usr/local/bin -xf /tmp/kubeconform.tar.gz kubeconform

# validate charts
for CHART_DIR in ${CHART_DIRS};do
  echo "helm dependency build…"
  helm dependency build "${CHART_DIR}"

  echo "kubeconform(ing) ${CHART_DIR##charts/} chart…"
  # The second schema location resolves CRD-based kinds (e.g. the ECK-managed
  # Elasticsearch resource) from the datree CRDs catalog.
  helm template "${CHART_DIR}" | kubeconform --strict --verbose \
    --schema-location default \
    --schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
    --kubernetes-version "${KUBERNETES_VERSION#v}"
done
