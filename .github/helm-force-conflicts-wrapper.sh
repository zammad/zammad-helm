#!/usr/bin/env bash
#
# Shadows the real `helm` binary on PATH during `ct install` to
#   strip flags from the subcommands that don't understand them.
#
# chart-testing's --helm-extra-args is passed to every helm subcommand it runs
# (install, upgrade, test, uninstall), and ct has no way to scope it per
# subcommand (helm/chart-testing#540, closed as not_planned). Two flags are
# only understood by install/upgrade/rollback:
#
#   --force-conflicts  Helm 4 defaults to Server-Side Apply, which conflicts
#                      with fields (e.g. .spec.nodeSets) the ECK operator takes
#                      ownership of after install, so `helm upgrade` needs it.
#   --wait-for-jobs    --wait alone does not wait for Jobs, so without this the
#                      release is reported ready while the init job is still
#                      migrating and seeding, and `helm test` then runs against
#                      a half-initialised installation.
#
# This wrapper strips both for every other subcommand, so they can stay in
# --helm-extra-args. Remove once chart-testing supports per-subcommand extra
# args.
#
# Expects $REAL_HELM to point at the actual helm binary.

set -o errexit
set -o pipefail

: "${REAL_HELM:?REAL_HELM must point at the real helm binary}"

case "${1:-}" in
install | upgrade | rollback)
  exec "${REAL_HELM}" "$@"
  ;;
*)
  args=()
  for arg in "$@"; do
    case "${arg}" in
    --force-conflicts | --wait-for-jobs) ;;
    *) args+=("${arg}") ;;
    esac
  done
  exec "${REAL_HELM}" "${args[@]}"
  ;;
esac
