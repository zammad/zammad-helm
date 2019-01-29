#!/bin/bash
#
# deploy zammad chart to zammad.github.io
#

set -o errexit
set -o pipefail

CHART_DIR="zammad"
CHART_REPO="git@github.com:zammad/zammad.github.io.git"
REPO_DIR="zammad.github.io"
REPO_ROOT="$(git rev-parse --show-toplevel)"

if [ -z "${CIRCLE_PULL_REQUEST}" ]; then

  if ! git diff --name-only HEAD~1 | grep -q 'zammad/Chart.yaml'; then
    echo "no chart changes... so no chart build and upload needed... exiting..."
    exit 0
  fi

  # get zammad.github.io
  test -d "${REPO_ROOT}"/"${REPO_DIR}" && rm -rf "${REPO_ROOT:=?}"/"${REPO_DIR:=?}"
  git clone "${CHART_REPO}" "${REPO_ROOT}"/"${REPO_DIR}"

  # get chart version
  CHART_VERSION="$(grep version: "${REPO_ROOT}"/"${CHART_DIR}"/Chart.yaml | sed 's/version: //')"

  # set original file dates of cloned repo
  (
  cd "${REPO_ROOT}"/"${REPO_DIR}" || exit
  while read -r FILE; do
    ORG_FILE_TIME=$(git log --pretty=format:%cd --date=format:'%y%m%d%H%M' "${FILE}" | tail -n 1)
    echo "set original time ${ORG_FILE_TIME} to ${FILE}"
    touch -c -t "${ORG_FILE_TIME}" "${FILE}"
  done < <(git ls-files)
  )

  # preserve dates in index.yaml by moving old charts and index out of the repo before packaging the new version
  mkdir -p "${REPO_ROOT}"/"${TMP_DIR}"
  mv "${REPO_ROOT}"/"${REPO_DIR}"/index.yaml "${REPO_ROOT}"/"${TMP_DIR}"
  mv "${REPO_ROOT}"/"${REPO_DIR}"/*.tgz "${REPO_ROOT}"/"${TMP_DIR}"

  # build helm dependencies in subshell
  (
  cd "${REPO_ROOT}"/"${CHART_DIR}" || exit
  helm dependency build
  )

  # build chart
  helm package "${REPO_ROOT}"/"${CHART_DIR}" --destination "${REPO_ROOT}"/"${REPO_DIR}"

  # build new index.yaml and merge with old one
  helm repo index --merge "${REPO_ROOT}"/"${TMP_DIR}"/index.yaml --url https://"${REPO_DIR}" "${REPO_ROOT}"/"${REPO_DIR}"

  # move old charts back into git repo
  mv "${REPO_ROOT}"/"${TMP_DIR}"/*.tgz "${REPO_ROOT}"/"${REPO_DIR}"

  # push changes to github
  cd "${REPO_ROOT}"/"${REPO_DIR}"
  git config --global user.email "CircleCi@circleci.com"
  git config --global user.name "Circle CI"
  git add --all .
  git commit -m "push zammad chart version ${CHART_VERSION} via circleci build nr: ${CIRCLE_BUILD_NUM}"
  git push --set-upstream origin master
else
  echo "skipped deploy as only merged pr in master is deployed..."
fi
