#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 4 ]]; then
  cat <<'EOF'
Usage:
  bash scripts/run_remote_validation_sequence.sh <ssh-target|auto> <candidate-slug> <candidate-branch> <candidate-train-script>

Examples:
  bash scripts/run_remote_validation_sequence.sh \
    auto \
    pr824-kgiir-lite \
    codex/pr824-kgiir-lite \
    experiments/pr824-kgiir-lite/train_gpt.py

  bash scripts/run_remote_validation_sequence.sh \
    runpod-pg-a \
    pr824-kgiir-lite \
    codex/pr824-kgiir-lite \
    experiments/pr824-kgiir-lite/train_gpt.py
EOF
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SSH_TARGET="$1"
CANDIDATE_SLUG="$2"
CANDIDATE_BRANCH="$3"
CANDIDATE_SCRIPT="$4"

REMOTE_REPO_DIR="${REMOTE_REPO_DIR:-/workspace/parameter-golf}"
REPO_REMOTE_URL="${REPO_REMOTE_URL:-$(git remote get-url origin)}"
SSH_OPTS="${SSH_OPTS:-}"
SSH_PORT="${SSH_PORT:-}"
PUSH_BRANCHES="${PUSH_BRANCHES:-1}"
PULL_AFTER_EACH="${PULL_AFTER_EACH:-1}"
BOOTSTRAP_DATA="${BOOTSTRAP_DATA:-1}"
LOCAL_RESULTS_ROOT="${LOCAL_RESULTS_ROOT:-$ROOT/remote_results}"
STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
RESULT_DIR="${LOCAL_RESULTS_ROOT}/${STAMP}_${CANDIDATE_SLUG}"
AUTO_RELEASE_POD="${AUTO_RELEASE_POD:-1}"
OWNER_LABEL="${OWNER_LABEL:-main-agent}"
START_STAGE="${START_STAGE:-baseline}"
SKIP_REMOTE_SETUP="${SKIP_REMOTE_SETUP:-0}"

AUTO_CLAIMED_POD_ID=""
AUTO_SSH_INFO_JSON=""

CONTROL_SLUG="${CONTROL_SLUG:-pr824-mimic}"
CONTROL_BRANCH="${CONTROL_BRANCH:-codex/pr824-mimic-gatedattn-valueresid}"
CONTROL_SCRIPT="${CONTROL_SCRIPT:-experiments/pr824-mimic-gatedattn-valueresid/train_gpt.py}"
BASELINE_SLUG="${BASELINE_SLUG:-baseline}"
BASELINE_BRANCH="${BASELINE_BRANCH:-main}"
BASELINE_SCRIPT="${BASELINE_SCRIPT:-train_gpt.py}"

BASELINE_ENV="${BASELINE_ENV:-}"
CONTROL_ENV="${CONTROL_ENV:-}"
CANDIDATE_ENV="${CANDIDATE_ENV:-}"
BASELINE_RUN_ID="${BASELINE_RUN_ID:-}"
CONTROL_RUN_ID="${CONTROL_RUN_ID:-}"
CANDIDATE_RUN_ID="${CANDIDATE_RUN_ID:-}"

mkdir -p "$RESULT_DIR"

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
    bash scripts/release_remote_validation_pod.sh "$AUTO_CLAIMED_POD_ID" >/dev/null || true
  fi
}
trap cleanup EXIT

if [[ "$SSH_TARGET" == "auto" ]]; then
  AUTO_SSH_INFO_JSON="$(bash scripts/claim_remote_validation_pod.sh "$OWNER_LABEL")"
  AUTO_CLAIMED_POD_ID="$(printf '%s' "$AUTO_SSH_INFO_JSON" | jq -r '.id')"
  SSH_TARGET="root@$(printf '%s' "$AUTO_SSH_INFO_JSON" | jq -r '.ip')"
  SSH_PORT="$(printf '%s' "$AUTO_SSH_INFO_JSON" | jq -r '.port')"
  printf '%s\n' "$AUTO_SSH_INFO_JSON" >"$RESULT_DIR/claimed_pod.json"
fi

push_branch_if_needed() {
  local branch="$1"
  if [[ "$PUSH_BRANCHES" != "1" ]]; then
    return 0
  fi
  if [[ "$branch" == "main" ]]; then
    git push origin main
  else
    git push -u origin "$branch"
  fi
}

stage_index() {
  case "$1" in
    baseline) echo 1 ;;
    control) echo 2 ;;
    candidate) echo 3 ;;
    *)
      echo "invalid stage: $1" >&2
      exit 2
      ;;
  esac
}

remote_setup() {
  ssh_cmd "$SSH_TARGET" \
    "REMOTE_REPO_DIR=$(printf '%q' "$REMOTE_REPO_DIR") REPO_REMOTE_URL=$(printf '%q' "$REPO_REMOTE_URL") BOOTSTRAP_DATA=$(printf '%q' "$BOOTSTRAP_DATA") bash -s" <<'EOF'
set -euo pipefail

if [[ ! -d "$REMOTE_REPO_DIR/.git" ]]; then
  if [[ -e "$REMOTE_REPO_DIR" ]]; then
    rm -rf "$REMOTE_REPO_DIR"
  fi
  mkdir -p "$(dirname "$REMOTE_REPO_DIR")"
  git clone "$REPO_REMOTE_URL" "$REMOTE_REPO_DIR"
fi

cd "$REMOTE_REPO_DIR"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "remote repo is dirty: $REMOTE_REPO_DIR" >&2
  exit 1
fi

git fetch origin
git switch main >/dev/null 2>&1 || git switch -c main --track origin/main
git pull --ff-only origin main

if [[ "$BOOTSTRAP_DATA" == "1" && ! -e ./data/datasets/fineweb10B_sp1024/fineweb_val_000000.bin ]]; then
  python3 data/cached_challenge_fineweb.py --variant sp1024
fi
EOF
}

run_stage() {
  local stage_name="$1"
  local branch="$2"
  local slug="$3"
  local script_path="$4"
  local extra_env="${5:-}"
  local run_id="remote_${CANDIDATE_SLUG}_${stage_name}_${STAMP}"

  echo "=== Running stage: $stage_name ==="
  echo "  branch: $branch"
  echo "  run_id: $run_id"

  ssh_cmd "$SSH_TARGET" \
    "REMOTE_REPO_DIR=$(printf '%q' "$REMOTE_REPO_DIR") BRANCH_NAME=$(printf '%q' "$branch") RUN_ID_VALUE=$(printf '%q' "$run_id") STAGE_SLUG=$(printf '%q' "$slug") TRAIN_SCRIPT=$(printf '%q' "$script_path") EXTRA_ENV=$(printf '%q' "$extra_env") bash -s" <<'EOF'
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

if [[ -n "$(git status --porcelain)" ]]; then
  echo "remote repo became dirty before stage run" >&2
  exit 1
fi

if [[ -n "$EXTRA_ENV" ]]; then
  eval "export $EXTRA_ENV"
fi
export RUN_ID="$RUN_ID_VALUE"
bash scripts/run_remote_experiment.sh "$STAGE_SLUG" "$TRAIN_SCRIPT"
EOF

  if [[ "$PULL_AFTER_EACH" == "1" ]]; then
    SSH_PORT="$SSH_PORT" bash scripts/pull_remote_run_artifacts.sh "$SSH_TARGET" "$run_id" "$RESULT_DIR/$stage_name"
  fi
}

cat >"$RESULT_DIR/sequence.meta.txt" <<EOF
ssh_target=$SSH_TARGET
ssh_port=$SSH_PORT
auto_claimed_pod_id=$AUTO_CLAIMED_POD_ID
remote_repo_dir=$REMOTE_REPO_DIR
repo_remote_url=$REPO_REMOTE_URL
candidate_slug=$CANDIDATE_SLUG
candidate_branch=$CANDIDATE_BRANCH
candidate_script=$CANDIDATE_SCRIPT
control_branch=$CONTROL_BRANCH
control_script=$CONTROL_SCRIPT
baseline_branch=$BASELINE_BRANCH
baseline_script=$BASELINE_SCRIPT
push_branches=$PUSH_BRANCHES
pull_after_each=$PULL_AFTER_EACH
bootstrapped_data=$BOOTSTRAP_DATA
auto_release_pod=$AUTO_RELEASE_POD
start_stage=$START_STAGE
skip_remote_setup=$SKIP_REMOTE_SETUP
baseline_run_id=$BASELINE_RUN_ID
control_run_id=$CONTROL_RUN_ID
candidate_run_id=$CANDIDATE_RUN_ID
started_at_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

push_branch_if_needed "$BASELINE_BRANCH"
push_branch_if_needed "$CONTROL_BRANCH"
push_branch_if_needed "$CANDIDATE_BRANCH"

if [[ "$SKIP_REMOTE_SETUP" != "1" ]]; then
  remote_setup
fi

if [[ "$(stage_index "$START_STAGE")" -gt 1 && -n "$BASELINE_RUN_ID" && "$PULL_AFTER_EACH" == "1" ]]; then
  SSH_PORT="$SSH_PORT" bash scripts/pull_remote_run_artifacts.sh "$SSH_TARGET" "$BASELINE_RUN_ID" "$RESULT_DIR/baseline"
fi

if [[ "$(stage_index "$START_STAGE")" -gt 2 && -n "$CONTROL_RUN_ID" && "$PULL_AFTER_EACH" == "1" ]]; then
  SSH_PORT="$SSH_PORT" bash scripts/pull_remote_run_artifacts.sh "$SSH_TARGET" "$CONTROL_RUN_ID" "$RESULT_DIR/control"
fi

if [[ "$(stage_index "$START_STAGE")" -le 1 ]]; then
  run_stage baseline "$BASELINE_BRANCH" "$BASELINE_SLUG" "$BASELINE_SCRIPT" "$BASELINE_ENV"
fi

if [[ "$(stage_index "$START_STAGE")" -le 2 ]]; then
  run_stage control "$CONTROL_BRANCH" "$CONTROL_SLUG" "$CONTROL_SCRIPT" "$CONTROL_ENV"
fi

if [[ "$(stage_index "$START_STAGE")" -le 3 ]]; then
  run_stage candidate "$CANDIDATE_BRANCH" "$CANDIDATE_SLUG" "$CANDIDATE_SCRIPT" "$CANDIDATE_ENV"
fi

echo "Sequence complete. Results are under: $RESULT_DIR"
