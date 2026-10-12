#!/usr/bin/env bash
# Nightly archive of the newest snapshot per profile to the NAS
set -Eeuo pipefail
SNAP=/var/lib/vz/mcsnaps; NAS=/mnt/pve/nas-backup/mcworlds-backup
mkdir -p "$NAS"
for d in "$SNAP"/*/; do
  p=$(basename "$d"); latest=$(ls -1d "$d"20* | tail -1)
  tar czf "$NAS/mc-$p-$(date +%F).tar.gz" -C "$latest" .
done
find "$NAS" -name 'mc-*.tar.gz' -mtime +14 -delete