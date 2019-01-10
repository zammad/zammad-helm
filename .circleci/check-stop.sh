#!/bin/sh
#
# lint charts
#

set -o errexit
set -o pipefail

CONFIG_DIR=".circleci"
GIT_REPO="https://github.com/zammad/helm"
REPO_ROOT="$(git rev-parse --show-toplevel)"
TMP_FILE="$(mktemp)"

git remote add k8s "${GIT_REPO}"
git fetch k8s master
ct lint --config="${REPO_ROOT}/${CONFIG_DIR}"/ct.yaml \
  --lint-conf="${REPO_ROOT}/${CONFIG_DIR}"/lintconf.yaml \
  --chart-yaml-schema="${REPO_ROOT}/${CONFIG_DIR}"/chart_schema.yaml > "${TMP_FILE}"

if grep -q 'No chart changes detected' < "${TMP_FILE}"; then
    curl -fLSs https://circle.ci/cli | sh
    circleci step halt
fi
