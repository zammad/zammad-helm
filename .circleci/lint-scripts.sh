#!/bin/sh
#
# lint bash scripts
#

set -o errexit

CONFIG_DIR="./.circleci"

while read -r FILE; do
  echo lint "${FILE}"
  shellcheck -x "${FILE}"
done < <(find "${CONFIG_DIR}" -type f -name "*.sh" > "${TMP_FILE}")
