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

: "${REAL_HELM:?REAL_HELM must point at the real helm binary}"

# The subcommand isn't necessarily $1: Helm's global flags (--namespace,
# --kube-context, ...) are valid before it too, e.g. `helm --namespace zammad
# upgrade ...`. Scan for the first non-flag token, skipping the value of any
# preceding flag that takes one. Helm's only boolean global flags are --debug
# and --kube-insecure-skip-tls-verify (see `helm help environment`); every
# other "-"-prefixed global flag takes a value.
find_subcommand() {
  local skip_next=false
  for arg in "$@"; do
    if [[ "${skip_next}" == true ]]; then
      skip_next=false
      continue
    fi
    case "${arg}" in
    --debug | --kube-insecure-skip-tls-verify | -h | --help)
      continue
      ;;
    -*)
      [[ "${arg}" == *=* ]] || skip_next=true
      continue
      ;;
    *)
      echo "${arg}"
      return
      ;;
    esac
  done
}

case "$(find_subcommand "$@")" in
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
