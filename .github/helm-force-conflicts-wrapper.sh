#!/usr/bin/env bash
#
# Shadows the real `helm` binary on PATH during `ct install` to
#   strip flags from the subcommands that don't understand them.
#
# chart-testing's --helm-extra-args is passed to every helm subcommand it runs
# (install, upgrade, test, uninstall), and ct has no way to scope it per
# subcommand (helm/chart-testing#540, closed as not_planned). Two flags need
# scoping, in opposite directions:
#
#   --force-conflicts  only install/upgrade/rollback accept it. Helm 4 defaults
#                      to Server-Side Apply, which conflicts with fields (e.g.
#                      .spec.nodeSets) the ECK operator takes ownership of after
#                      install, so `helm upgrade` needs it.
#   --logs             only `helm test` accepts it. It dumps the test pod logs,
#                      which is the only way a failing helm test reports what it
#                      actually saw: ct prints namespace events, never pod logs.
#
# This wrapper keeps each flag for the subcommands that accept it and strips it
# everywhere else, so both can stay in --helm-extra-args.
# Remove once chart-testing supports per-subcommand extra args.
#
# Expects $REAL_HELM to point at the actual helm binary.

set -o errexit
set -o pipefail

: "${REAL_HELM:?REAL_HELM must point at the real helm binary}"

case "${1:-}" in
install | upgrade | rollback)
  strip=("--logs")
  ;;
test)
  strip=("--force-conflicts")
  ;;
*)
  strip=("--force-conflicts" "--logs")
  ;;
esac

args=()
for arg in "$@"; do
  keep=1
  for unsupported in "${strip[@]}"; do
    [[ "${arg}" == "${unsupported}" ]] && keep=0
  done
  if ((keep)); then
    args+=("${arg}")
  fi
done

exec "${REAL_HELM}" "${args[@]}"
