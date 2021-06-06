#!/bin/bash
#
# use kubeval to validate helm generated kubernetes manifest
#

set -o errexit
set -o pipefail

CHART_DIRS="$(git diff --find-renames --name-only "$(git rev-parse --abbrev-ref HEAD)" remotes/origin/master -- zammad | grep '[cC]hart.yaml' | sed -e 's#/[Cc]hart.yaml##g')"
KUBEVAL_VERSION="0.16.1"
SCHEMA_LOCATION="https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/"

# install kubeval
curl --silent --show-error --fail --location --output /tmp/kubeval.tar.gz https://github.com/instrumenta/kubeval/releases/download/"${KUBEVAL_VERSION}"/kubeval-linux-amd64.tar.gz
sudo tar -C /usr/local/bin -xf /tmp/kubeval.tar.gz kubeval

# validate charts
for CHART_DIR in ${CHART_DIRS};do
  echo "helm dependency build..."
  helm dependency build "${CHART_DIR}"

  echo "kubeval(idating) ${CHART_DIR##charts/} chart..."
  helm template "${CHART_DIR}" | kubeval --strict --ignore-missing-schemas --kubernetes-version "${KUBERNETES_VERSION#v}" --schema-location "${SCHEMA_LOCATION}"
done
