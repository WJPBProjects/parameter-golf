#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  cat <<'EOF'
Usage:
  bash scripts/pull_remote_run_artifacts.sh <ssh-target> <run-id> [local-dest-dir]

Examples:
  bash scripts/pull_remote_run_artifacts.sh runpod-pg-a remote_baseline_20260406_120000
  bash scripts/pull_remote_run_artifacts.sh runpod-pg-a remote_baseline_20260406_120000 ./remote_results/baseline-a
EOF
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SSH_TARGET="$1"
RUN_ID="$2"
LOCAL_DEST_DIR="${3:-$ROOT/remote_results/$RUN_ID}"
REMOTE_REPO_DIR="${REMOTE_REPO_DIR:-/workspace/parameter-golf}"
SSH_OPTS="${SSH_OPTS:-}"

mkdir -p "$LOCAL_DEST_DIR/logs" "$LOCAL_DEST_DIR/artifacts"

copy_required() {
  local remote_rel="$1"
  local local_path="$2"
  local remote_path="${REMOTE_REPO_DIR}/${remote_rel}"
  echo "Pulling required file: ${remote_rel}"
  # shellcheck disable=SC2086
  scp $SSH_OPTS "${SSH_TARGET}:${remote_path}" "$local_path"
}

copy_optional() {
  local remote_rel="$1"
  local local_path="$2"
  local remote_path="${REMOTE_REPO_DIR}/${remote_rel}"
  # shellcheck disable=SC2086
  if ssh $SSH_OPTS "$SSH_TARGET" "test -f $(printf '%q' "$remote_path")"; then
    echo "Pulling optional file: ${remote_rel}"
    # shellcheck disable=SC2086
    scp $SSH_OPTS "${SSH_TARGET}:${remote_path}" "$local_path"
  else
    echo "Optional file missing: ${remote_rel}"
  fi
}

copy_required "logs/${RUN_ID}.txt" "$LOCAL_DEST_DIR/logs/${RUN_ID}.txt"
copy_required "logs/${RUN_ID}.remote.meta.txt" "$LOCAL_DEST_DIR/logs/${RUN_ID}.remote.meta.txt"
copy_required "logs/${RUN_ID}.summary.txt" "$LOCAL_DEST_DIR/logs/${RUN_ID}.summary.txt"
copy_optional "artifacts/${RUN_ID}/final_model.int8.ptz" "$LOCAL_DEST_DIR/artifacts/final_model.int8.ptz"
copy_optional "artifacts/${RUN_ID}/final_model.pt" "$LOCAL_DEST_DIR/artifacts/final_model.pt"

cat >"$LOCAL_DEST_DIR/pull.meta.txt" <<EOF
ssh_target=$SSH_TARGET
run_id=$RUN_ID
remote_repo_dir=$REMOTE_REPO_DIR
local_dest_dir=$LOCAL_DEST_DIR
pulled_at_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo
echo "Pulled files into: $LOCAL_DEST_DIR"
if [[ -f "$LOCAL_DEST_DIR/logs/${RUN_ID}.summary.txt" ]]; then
  echo
  cat "$LOCAL_DEST_DIR/logs/${RUN_ID}.summary.txt"
fi
