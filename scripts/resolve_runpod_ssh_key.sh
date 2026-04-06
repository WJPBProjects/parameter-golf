#!/usr/bin/env bash

set -euo pipefail

# Find a local private key whose public fingerprint matches a key registered in RunPod.

registered_fingerprints="$(runpodctl ssh list-keys | jq -r '.keys[]?.fingerprint // empty' || true)"
if [[ -z "$registered_fingerprints" ]]; then
  exit 1
fi

shopt -s nullglob
for pub in "$HOME"/.ssh/*.pub; do
  fingerprint="$(ssh-keygen -lf "$pub" | awk '{print $2}')"
  if printf '%s\n' "$registered_fingerprints" | grep -Fxq "$fingerprint"; then
    priv="${pub%.pub}"
    if [[ -f "$priv" ]]; then
      printf '%s\n' "$priv"
      exit 0
    fi
  fi
done

exit 1
