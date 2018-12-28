#!/bin/bash
#
# trigger build of https://github.com/zammad/helm in https://github.com/zammad/zammad.github.io
#

REPO_USER="zammad"
REPO="helm"
BRANCH="master"

if [ "${TRAVIS_BRANCH}" == 'master' ]; then
  curl -X POST \
    -H "Content-Type: application/json" \
    -H "Travis-API-Version: 3" \
    -H "Accept: application/json" \
    -H "Authorization: token ${TRAVIS_API_TOKEN}" \
    -d '{"request":{ "message": "'"${TRAVIS_COMMIT_MESSAGE}"'","branch":"'${BRANCH}'"}}' \
    "https://api.travis-ci.org/repo/${REPO_USER}%2F${REPO}/requests"
fi
