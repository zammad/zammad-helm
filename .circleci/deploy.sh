#!/bin/bash
#
# build zammad chart and upload to zammad.github.io
#

set -ex

CHART_DIR="zammad"
CHART_REPO="git@github.com:zammad/zammad.github.io.git"
REPO_DIR="zammad.github.io"
REPO_ROOT="$(git rev-parse --show-toplevel)"

if [ "${CIRCLECI}" == 'true' ] && [ -z "${CIRCLE_PULL_REQUEST}" ]; then

  # get zammad.github.io
  test -d "${REPO_ROOT}"/"${REPO_DIR}" && rm -rf "${REPO_ROOT:=?}"/"${REPO_DIR:=?}"
  git clone "${CHART_REPO}" "${REPO_ROOT}"/"${REPO_DIR}"

  # get chart version
  CHART_VERSION="$(grep version: "${REPO_ROOT}"/"${CHART_DIR}"/Chart.yaml | sed 's/version: //')"

  # build helm dependencies in subshell
  (
  cd "${REPO_ROOT}"/"${CHART_DIR}" || exit
  helm dependency build
  )

  # build chart
  helm package "${REPO_ROOT}"/"${CHART_DIR}" --destination "${REPO_ROOT}"/"${REPO_DIR}"

  helm repo index --merge "${REPO_ROOT}"/"${REPO_DIR}"/index.yaml --url https://zammad.github.io "${REPO_ROOT}"/"${REPO_DIR}"

  # push changes to github

  cd "${REPO_ROOT}"/"${REPO_DIR}"
  git config --global user.email "CircleCi@circleci.com"
  git config --global user.name "Circle CI"
  git add --all .
  git commit -m "push zammad chart version ${CHART_VERSION} via circleci build nr: ${CIRCLE_BUILD_NUM} - [skip ci]"
  git push --set-upstream origin master
fi
