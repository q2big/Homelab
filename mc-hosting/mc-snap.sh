#!/usr/bin/env bash
# mc-snap.sh take | list <profile> | restore <profile> <timestamp>
set -Eeuo pipefail
VMID=220; DIR=/var/lib/vz/mcworlds; SNAP=/var/lib/vz/mcsnaps; KEEP=96
vm() { qm guest exec "$VMID" --timeout 120 -- "$@" >/dev/null; }
case "${1:?take|list|restore}" in
  take)
    vm docker exec minecraft mc-send-to-console save-off || true
    trap 'vm docker exec minecraft mc-send-to-console save-on || true' EXIT
    vm docker exec minecraft mc-send-to-console "save-all flush" || true
    sleep 3
    for p in $(ls "$DIR"); do
      mkdir -p "$SNAP/$p"
      latest=$(ls -1d "$SNAP/$p"/20* 2>/dev/null | tail -1 || true)
      rsync -a --exclude=logs --exclude=cache --link-dest="${latest:-/nonexistent}" \
        "$DIR/$p/" "$SNAP/$p/$(date +%F-%H%M%S)/"
      ls -1d "$SNAP/$p"/20* | head -n -"$KEEP" | xargs -r rm -rf
    done ;;
  list) ls -1 "$SNAP/${2:?profile}" ;;
  restore)
    p=${2:?profile}; ts=${3:?timestamp}
    [[ -d "$SNAP/$p/$ts" ]] || { echo "FAIL no such snapshot"; exit 1; }
    vm docker stop minecraft
    find "$DIR/$p" -mindepth 1 -delete
    rsync -a "$SNAP/$p/$ts/" "$DIR/$p/"
    vm docker start minecraft
    echo "OK  restored $p to $ts" ;;
esac