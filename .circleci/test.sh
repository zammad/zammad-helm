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



  # get zammad.github.io
  test -d "${REPO_ROOT}"/"${REPO_DIR}" && rm -rf "${REPO_ROOT:=?}"/"${REPO_DIR:=?}"
  git clone "${CHART_REPO}" "${REPO_ROOT}"/"${REPO_DIR}"

  # get chart version
  CHART_VERSION="$(grep version: "${REPO_ROOT}"/"${CHART_DIR}"/Chart.yaml | sed 's/version: //')"

  # set original file dates
  (
  cd "${REPO_ROOT}"/"${REPO_DIR}" || exit
  ls -al
  while read -r FILE; do
    ORG_FILE_TIME=$(git log --pretty=format:%cd -n 1 --date=local "${FILE}")
    echo "set original time ${ORG_FILE_TIME} to ${FILE}"
    touch -c -d "${ORG_FILE_TIME}" -m "${FILE}"
  done < <(git ls-files)
  ls -al
  )
