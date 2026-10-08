#!/usr/bin/env bash
# Runs a command inside the homelab-tools container.
# Usage: tools/run.sh tofu plan
#        tools/run.sh            (interactive shell)
set -euo pipefail

IMAGE="homelab-tools:local"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_DIR="${HOMELAB_SECRETS_DIR:-$HOME/.config/homelab}"

mkdir -p "$SECRETS_DIR"
chmod 700 "$SECRETS_DIR"

args=(run --rm -i --userns=keep-id
  -v "$REPO_ROOT":/work:Z
  -v "$SECRETS_DIR":/secrets:Z
  -e SOPS_AGE_KEY_FILE=/secrets/age.key
  -w /work)

[[ -t 0 ]] && args+=(-t)
[[ -f "$SECRETS_DIR/env" ]] && args+=(--env-file "$SECRETS_DIR/env")

exec podman "${args[@]}" "$IMAGE" "$@"
