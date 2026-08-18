#!/usr/bin/env bash
#
# Shadows the real `helm` binary on PATH during `ct install` to
#   strip `--force-conflicts` for subcommands that don't understand it.
#
# Helm 4 defaults to Server-Side Apply, which conflicts with fields (e.g.
# .spec.nodeSets) the ECK operator takes ownership of after install, so
# `helm upgrade` needs --force-conflicts. But chart-testing's
# --helm-extra-args is passed to every helm subcommand it runs (install,
# upgrade, test, uninstall), and --force-conflicts is only accepted by
# install/upgrade/rollback - ct has no way to scope it per subcommand
# (helm/chart-testing#540, closed as not_planned). This wrapper strips
# --force-conflicts for any subcommand that doesn't understand it, so it can
# stay in --helm-extra-args without breaking `helm test`/`helm uninstall`.
# Remove once chart-testing supports per-subcommand extra args.
#
# Expects $REAL_HELM to point at the actual helm binary.

set -o errexit
set -o pipefail
set -o nounset

case "${1:-}" in
install | upgrade | rollback)
  exec "${REAL_HELM}" "$@"
  ;;
*)
  args=()
  for arg in "$@"; do
    [[ "${arg}" == "--force-conflicts" ]] || args+=("${arg}")
  done
  exec "${REAL_HELM}" "${args[@]}"
  ;;
esac
