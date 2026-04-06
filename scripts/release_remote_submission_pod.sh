#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  cat <<'EOF'
Usage:
  bash scripts/release_remote_submission_pod.sh <pod-id>
EOF
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

POD_ID="$1"
CLAIMS_DIR="${CLAIMS_DIR:-$ROOT/codex_notes/coordination_live/remote_submission_claims}"
STOP_POD="${STOP_POD:-1}"
CLAIM_DIR="$CLAIMS_DIR/$POD_ID"

if [[ "$STOP_POD" == "1" ]]; then
  runpodctl pod stop "$POD_ID" >/dev/null 2>&1 || true
fi

rm -rf "$CLAIM_DIR"

cat <<EOF
{
  "pod_id": "$POD_ID",
  "stopped": $([[ "$STOP_POD" == "1" ]] && echo true || echo false),
  "released_at_utc": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
