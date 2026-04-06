#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  cat <<'EOF'
Usage:
  bash scripts/run_remote_submission_batch.sh <auto|ssh-target> <queue.tsv>

Queue format:
  slug<TAB>branch<TAB>train_script<TAB>extra_env(optional)

Example:
  bash scripts/run_remote_submission_batch.sh auto codex_notes/coordination/submission_batch_queue.tsv
EOF
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

TARGET="$1"
QUEUE_FILE="$2"

if [[ ! -f "$QUEUE_FILE" ]]; then
  echo "queue file not found: $QUEUE_FILE" >&2
  exit 1
fi

REPO_REMOTE_URL="${REPO_REMOTE_URL:-$(git remote get-url origin)}"
REMOTE_REPO_DIR="${REMOTE_REPO_DIR:-/workspace/parameter-golf}"
LOCAL_RESULTS_ROOT="${LOCAL_RESULTS_ROOT:-$ROOT/remote_results/submission_batches}"
OWNER_LABEL="${OWNER_LABEL:-main-agent}"
AUTO_RELEASE_POD="${AUTO_RELEASE_POD:-1}"
PUSH_BRANCHES="${PUSH_BRANCHES:-1}"
BOOTSTRAP_DATA="${BOOTSTRAP_DATA:-1}"
RUN_TIMEOUT_SECONDS="${RUN_TIMEOUT_SECONDS:-5400}"
POLL_SECONDS="${POLL_SECONDS:-20}"
SSH_OPTS="${SSH_OPTS:-}"
SSH_PORT="${SSH_PORT:-}"

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
BATCH_NAME="${BATCH_NAME:-$(basename "$QUEUE_FILE" | sed 's/\.[^.]*$//')}"
RESULT_DIR="${LOCAL_RESULTS_ROOT}/${STAMP}_${BATCH_NAME}"
mkdir -p "$RESULT_DIR"

AUTO_CLAIMED_POD_ID=""

if [[ -z "$SSH_OPTS" ]]; then
  if resolved_key="$(bash "$ROOT/scripts/resolve_runpod_ssh_key.sh" 2>/dev/null)"; then
    SSH_OPTS="-i $resolved_key -o StrictHostKeyChecking=accept-new -o BatchMode=yes"
  else
    SSH_OPTS="-o StrictHostKeyChecking=accept-new -o BatchMode=yes"
  fi
fi

ssh_cmd() {
  if [[ -n "$SSH_PORT" ]]; then
    # shellcheck disable=SC2086
    ssh $SSH_OPTS -p "$SSH_PORT" "$@"
  else
    # shellcheck disable=SC2086
    ssh $SSH_OPTS "$@"
  fi
}

cleanup() {
  if [[ -n "$AUTO_CLAIMED_POD_ID" && "$AUTO_RELEASE_POD" == "1" ]]; then
    bash "$ROOT/scripts/release_remote_submission_pod.sh" "$AUTO_CLAIMED_POD_ID" >/dev/null || true
  fi
}
trap cleanup EXIT

if [[ "$TARGET" == "auto" ]]; then
  ssh_info="$(bash "$ROOT/scripts/claim_remote_submission_pod.sh" "$OWNER_LABEL")"
  AUTO_CLAIMED_POD_ID="$(printf '%s' "$ssh_info" | jq -r '.id')"
  TARGET="root@$(printf '%s' "$ssh_info" | jq -r '.ip')"
  SSH_PORT="$(printf '%s' "$ssh_info" | jq -r '.port')"
  printf '%s\n' "$ssh_info" >"$RESULT_DIR/claimed_pod.json"
fi

push_branch_if_needed() {
  local branch="$1"
  if [[ "$PUSH_BRANCHES" != "1" ]]; then
    return 0
  fi
  if [[ "$branch" == "main" ]]; then
    git push origin main >/dev/null
  else
    git push -u origin "$branch" >/dev/null
  fi
}

bootstrap_remote() {
  ssh_cmd "$TARGET" \
    "REMOTE_REPO_DIR=$(printf '%q' "$REMOTE_REPO_DIR") REPO_REMOTE_URL=$(printf '%q' "$REPO_REMOTE_URL") BOOTSTRAP_DATA=$(printf '%q' "$BOOTSTRAP_DATA") bash -s" <<'EOF'
set -euo pipefail

if [[ ! -d "$REMOTE_REPO_DIR/.git" ]]; then
  rm -rf "$REMOTE_REPO_DIR"
  mkdir -p "$(dirname "$REMOTE_REPO_DIR")"
  git clone "$REPO_REMOTE_URL" "$REMOTE_REPO_DIR"
fi

cd "$REMOTE_REPO_DIR"
git fetch origin
git switch main >/dev/null 2>&1 || git switch -c main --track origin/main
git pull --ff-only origin main

if [[ "$BOOTSTRAP_DATA" == "1" && ! -e ./data/datasets/fineweb10B_sp1024/fineweb_val_000000.bin ]]; then
  python3 data/cached_challenge_fineweb.py --variant sp1024
fi
EOF
}

copy_runner_to_remote() {
  cat "$ROOT/scripts/run_remote_submission_8xh100.sh" | ssh_cmd "$TARGET" \
    "mkdir -p $(printf '%q' "$REMOTE_REPO_DIR/.codex_tmp") && cat > $(printf '%q' "$REMOTE_REPO_DIR/.codex_tmp/run_remote_submission_8xh100.sh") && chmod +x $(printf '%q' "$REMOTE_REPO_DIR/.codex_tmp/run_remote_submission_8xh100.sh")"
}

finalize_remote_run() {
  local run_id="$1"
  local train_script="$2"
  ssh_cmd "$TARGET" \
    "REMOTE_REPO_DIR=$(printf '%q' "$REMOTE_REPO_DIR") RUN_ID_VALUE=$(printf '%q' "$run_id") TRAIN_SCRIPT=$(printf '%q' "$train_script") bash -s" <<'EOF'
set -euo pipefail
cd "$REMOTE_REPO_DIR"
mkdir -p "artifacts/$RUN_ID_VALUE"
if [[ -f final_model.pt ]]; then mv -f final_model.pt "artifacts/$RUN_ID_VALUE/final_model.pt"; fi
if [[ -f final_model.int8.ptz ]]; then mv -f final_model.int8.ptz "artifacts/$RUN_ID_VALUE/final_model.int8.ptz"; fi
if [[ -f final_model.int6.ptz ]]; then mv -f final_model.int6.ptz "artifacts/$RUN_ID_VALUE/final_model.int6.ptz"; fi
{
  echo "status=OK_MONITORED"
  echo "stage=submission_8xh100"
  echo "command_exit_code=final_metric_detected"
  echo "finished_at_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "log_path=logs/$RUN_ID_VALUE.txt"
  grep -E "world_size:|final_int(6|8)_roundtrip|Serialized model int(6|8)\+zlib|Total submission size int(6|8)\+zlib|step_avg:|stopping_early:" "logs/$RUN_ID_VALUE.txt" | tail -n 24 || true
  [[ -f "artifacts/$RUN_ID_VALUE/final_model.pt" ]] && echo "artifact_model_pt=artifacts/$RUN_ID_VALUE/final_model.pt"
  [[ -f "artifacts/$RUN_ID_VALUE/final_model.int8.ptz" ]] && echo "artifact_model_ptz=artifacts/$RUN_ID_VALUE/final_model.int8.ptz"
  [[ -f "artifacts/$RUN_ID_VALUE/final_model.int6.ptz" ]] && echo "artifact_model_ptz=artifacts/$RUN_ID_VALUE/final_model.int6.ptz"
} >"logs/$RUN_ID_VALUE.summary.txt"
pkill -f "$TRAIN_SCRIPT" >/dev/null 2>&1 || true
pkill -f 'run_remote_submission_8xh100.sh' >/dev/null 2>&1 || true
EOF
}

run_one() {
  local slug="$1"
  local branch="$2"
  local train_script="$3"
  local extra_env="$4"
  local run_id="submission8x_${slug}_$(date +%Y%m%d_%H%M%S)"
  local case_dir="$RESULT_DIR/$slug"
  mkdir -p "$case_dir"

  echo "=== submission candidate: $slug ==="
  echo "  branch: $branch"
  echo "  run_id: $run_id"

  push_branch_if_needed "$branch"
  copy_runner_to_remote

  ssh_cmd "$TARGET" \
    "REMOTE_REPO_DIR=$(printf '%q' "$REMOTE_REPO_DIR") BRANCH_NAME=$(printf '%q' "$branch") RUN_ID_VALUE=$(printf '%q' "$run_id") STAGE_SLUG=$(printf '%q' "$slug") TRAIN_SCRIPT=$(printf '%q' "$train_script") EXTRA_ENV=$(printf '%q' "$extra_env") bash -s" <<'EOF'
set -euo pipefail
cd "$REMOTE_REPO_DIR"
git fetch origin
if [[ "$BRANCH_NAME" == "main" ]]; then
  git switch main
  git pull --ff-only origin main
else
  git fetch origin "$BRANCH_NAME"
  git switch -C "$BRANCH_NAME" --track "origin/$BRANCH_NAME" >/dev/null 2>&1 || git switch "$BRANCH_NAME"
fi
rm -rf .codex_tmp/*.launch.txt 2>/dev/null || true
rm -f final_model.pt final_model.int8.ptz final_model.int6.ptz
if [[ -n "$EXTRA_ENV" ]]; then
  eval "export $EXTRA_ENV"
fi
export RUN_ID="$RUN_ID_VALUE"
nohup bash "$REMOTE_REPO_DIR/.codex_tmp/run_remote_submission_8xh100.sh" "$STAGE_SLUG" "$TRAIN_SCRIPT" >"$REMOTE_REPO_DIR/.codex_tmp/${RUN_ID_VALUE}.launch.txt" 2>&1 &
echo $! >"$REMOTE_REPO_DIR/.codex_tmp/${RUN_ID_VALUE}.pid"
EOF

  deadline=$(( $(date +%s) + RUN_TIMEOUT_SECONDS ))
  final_detected=0
  while (( $(date +%s) < deadline )); do
    log_tail="$(ssh_cmd "$TARGET" "test -f $(printf '%q' "$REMOTE_REPO_DIR/logs/$run_id.txt") && tail -n 40 $(printf '%q' "$REMOTE_REPO_DIR/logs/$run_id.txt") || true")"
    if [[ "$log_tail" == *"final_int6_roundtrip_exact"* || "$log_tail" == *"final_int8_zlib_roundtrip_exact"* ]]; then
      final_detected=1
      break
    fi
    sleep "$POLL_SECONDS"
  done

  if [[ "$final_detected" != "1" ]]; then
    echo "timed out waiting for final metric for $slug" >&2
    ssh_cmd "$TARGET" "tail -n 120 $(printf '%q' "$REMOTE_REPO_DIR/logs/$run_id.txt") 2>/dev/null || true" >"$case_dir/timeout_tail.txt" || true
    return 1
  fi

  finalize_remote_run "$run_id" "$train_script"
  SSH_PORT="$SSH_PORT" bash "$ROOT/scripts/pull_remote_run_artifacts.sh" "$TARGET" "$run_id" "$case_dir"
}

bootstrap_remote

while IFS=$'\t' read -r slug branch train_script extra_env; do
  [[ -z "${slug:-}" ]] && continue
  [[ "${slug:0:1}" == "#" ]] && continue
  run_one "$slug" "$branch" "$train_script" "${extra_env:-}"
done <"$QUEUE_FILE"
