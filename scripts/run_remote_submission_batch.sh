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
REMOTE_VAL_LOSS_EVERY_DEFAULT="${REMOTE_VAL_LOSS_EVERY_DEFAULT:-1500}"
EARLY_STOP_ENABLE="${EARLY_STOP_ENABLE:-1}"
EARLY_STOP_FRACTION="${EARLY_STOP_FRACTION:-0.65}"
EARLY_STOP_MARGIN_BPB="${EARLY_STOP_MARGIN_BPB:-0.0300}"
EARLY_STOP_LOG_TAIL_LINES="${EARLY_STOP_LOG_TAIL_LINES:-400}"
EARLY_STOP_MIN_CHECKPOINTS="${EARLY_STOP_MIN_CHECKPOINTS:-2}"
EARLY_STOP_MIN_IMPROVEMENT_BPB="${EARLY_STOP_MIN_IMPROVEMENT_BPB:-0.0050}"
SHARED_REFERENCE_CURVE_FILE="${SHARED_REFERENCE_CURVE_FILE:-$ROOT/codex_notes/coordination_live/submission_reference_curve.tsv}"
QUEUE_REFERENCE_FALLBACK="${QUEUE_REFERENCE_FALLBACK:-1}"
PROMOTE_QUEUE_REFERENCE_TO_SHARED="${PROMOTE_QUEUE_REFERENCE_TO_SHARED:-0}"

STAMP="${STAMP:-$(date +%Y%m%d_%H%M%S)}"
BATCH_NAME="${BATCH_NAME:-$(basename "$QUEUE_FILE" | sed 's/\.[^.]*$//')}"
RESULT_DIR="${LOCAL_RESULTS_ROOT}/${STAMP}_${BATCH_NAME}"
mkdir -p "$RESULT_DIR"
QUEUE_REFERENCE_CURVE_FILE="$RESULT_DIR/reference_curve.tsv"

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

augment_extra_env() {
  local extra_env="$1"
  if [[ "$extra_env" != *"VAL_LOSS_EVERY="* ]]; then
    if [[ -n "$extra_env" ]]; then
      extra_env="$extra_env "
    fi
    extra_env="${extra_env}VAL_LOSS_EVERY=$REMOTE_VAL_LOSS_EVERY_DEFAULT"
  fi
  printf '%s' "$extra_env"
}

resolve_env_value() {
  local extra_env="$1"
  local var_name="$2"
  local default_value="$3"
  EXTRA_ENV_VALUE="$extra_env" VAR_NAME="$var_name" DEFAULT_VALUE="$default_value" python3 - <<'PY'
import os, subprocess
extra = os.environ["EXTRA_ENV_VALUE"]
var_name = os.environ["VAR_NAME"]
default = os.environ["DEFAULT_VALUE"]
script = f'export {extra} >/dev/null 2>&1 || true; printf "%s" "${{{var_name}:-{default}}}"'
value = subprocess.check_output(["bash", "-lc", script], text=True).strip()
print(value)
PY
}

extract_validation_curve() {
  local log_path="$1"
  local out_path="$2"
  python3 - "$log_path" "$out_path" <<'PY'
import re
import sys
from pathlib import Path

log_path = Path(sys.argv[1])
out_path = Path(sys.argv[2])
pat = re.compile(r"step:(\d+)/(\d+)\s+val_loss:([0-9.]+)\s+val_bpb:([0-9.]+)\s+train_time:(\d+)ms step_avg:([0-9.]+)ms")
rows = []
for line in log_path.read_text(errors="ignore").splitlines():
    m = pat.search(line)
    if not m:
        continue
    rows.append((int(m.group(5)), int(m.group(1)), float(m.group(4)), float(m.group(6))))
out_path.parent.mkdir(parents=True, exist_ok=True)
with out_path.open("w") as f:
    f.write("train_time_ms\tstep\tval_bpb\tstep_avg_ms\n")
    for train_time_ms, step, val_bpb, step_avg_ms in rows:
        f.write(f"{train_time_ms}\t{step}\t{val_bpb:.8f}\t{step_avg_ms:.4f}\n")
PY
}

should_early_stop() {
  local log_tail="$1"
  local reference_curve_file="$2"
  local max_wallclock_seconds="$3"
  local fraction="$4"
  local margin_bpb="$5"
  local min_checkpoints="$6"
  local min_improvement_bpb="$7"
  LOG_TAIL_INPUT="$log_tail" REFERENCE_CURVE_FILE_INPUT="$reference_curve_file" MAX_WALLCLOCK_SECONDS_INPUT="$max_wallclock_seconds" FRACTION_INPUT="$fraction" MARGIN_BPB_INPUT="$margin_bpb" MIN_CHECKPOINTS_INPUT="$min_checkpoints" MIN_IMPROVEMENT_BPB_INPUT="$min_improvement_bpb" python3 - <<'PY'
import os
import re
import sys
from pathlib import Path

text = os.environ["LOG_TAIL_INPUT"]
reference_curve = Path(os.environ["REFERENCE_CURVE_FILE_INPUT"])
max_wallclock_seconds = float(os.environ["MAX_WALLCLOCK_SECONDS_INPUT"])
fraction = float(os.environ["FRACTION_INPUT"])
margin_bpb = float(os.environ["MARGIN_BPB_INPUT"])
min_checkpoints = int(os.environ["MIN_CHECKPOINTS_INPUT"])
min_improvement_bpb = float(os.environ["MIN_IMPROVEMENT_BPB_INPUT"])

pat = re.compile(r"step:(\d+)/(\d+)\s+val_loss:([0-9.]+)\s+val_bpb:([0-9.]+)\s+train_time:(\d+)ms step_avg:([0-9.]+)ms")
checkpoints = []
for line in text.splitlines():
    m = pat.search(line)
    if m:
        checkpoints.append({
            "step": int(m.group(1)),
            "val_bpb": float(m.group(4)),
            "train_time_ms": int(m.group(5)),
            "step_avg_ms": float(m.group(6)),
        })

if not checkpoints:
    print("NO_CHECKPOINT")
    sys.exit(0)

if len(checkpoints) < min_checkpoints:
    print("WAIT")
    sys.exit(0)

latest = checkpoints[-1]
previous = checkpoints[-2]
recent_improvement = previous["val_bpb"] - latest["val_bpb"]

threshold_ms = int(max_wallclock_seconds * fraction * 1000)
if latest["train_time_ms"] < threshold_ms:
    print("WAIT")
    sys.exit(0)

if not reference_curve.exists():
    print("NO_REFERENCE")
    sys.exit(0)

ref_rows = []
for raw in reference_curve.read_text().splitlines()[1:]:
    if not raw.strip():
        continue
    train_time_ms, step, val_bpb, step_avg_ms = raw.split("\t")
    ref_rows.append({
        "train_time_ms": int(train_time_ms),
        "step": int(step),
        "val_bpb": float(val_bpb),
        "step_avg_ms": float(step_avg_ms),
    })

eligible = [row for row in ref_rows if row["train_time_ms"] <= latest["train_time_ms"]]
if not eligible:
    print("WAIT")
    sys.exit(0)

ref = eligible[-1]
delta = latest["val_bpb"] - ref["val_bpb"]
if delta > margin_bpb and recent_improvement < min_improvement_bpb:
    print(
        "EARLY_STOP "
        f"candidate_step={latest['step']} "
        f"candidate_train_time_ms={latest['train_time_ms']} "
        f"candidate_val_bpb={latest['val_bpb']:.6f} "
        f"previous_val_bpb={previous['val_bpb']:.6f} "
        f"recent_improvement_bpb={recent_improvement:.6f} "
        f"reference_step={ref['step']} "
        f"reference_train_time_ms={ref['train_time_ms']} "
        f"reference_val_bpb={ref['val_bpb']:.6f} "
        f"delta_bpb={delta:.6f}"
    )
else:
    print(
        "KEEP "
        f"candidate_step={latest['step']} "
        f"candidate_train_time_ms={latest['train_time_ms']} "
        f"candidate_val_bpb={latest['val_bpb']:.6f} "
        f"previous_val_bpb={previous['val_bpb']:.6f} "
        f"recent_improvement_bpb={recent_improvement:.6f} "
        f"reference_val_bpb={ref['val_bpb']:.6f} "
        f"delta_bpb={delta:.6f}"
    )
PY
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

stop_remote_run() {
  local train_script="$1"
  ssh_cmd "$TARGET" \
    "TRAIN_SCRIPT=$(printf '%q' "$train_script") bash -s" <<'EOF'
set -euo pipefail
pkill -f "$TRAIN_SCRIPT" >/dev/null 2>&1 || true
pkill -f 'run_remote_submission_8xh100.sh' >/dev/null 2>&1 || true
EOF
}

finalize_remote_run() {
  local run_id="$1"
  local train_script="$2"
  local result_status="${3:-OK_MONITORED}"
  local result_reason="${4:-final_metric_detected}"
  ssh_cmd "$TARGET" \
    "REMOTE_REPO_DIR=$(printf '%q' "$REMOTE_REPO_DIR") RUN_ID_VALUE=$(printf '%q' "$run_id") TRAIN_SCRIPT=$(printf '%q' "$train_script") RESULT_STATUS=$(printf '%q' "$result_status") RESULT_REASON=$(printf '%q' "$result_reason") bash -s" <<'EOF'
set -euo pipefail
cd "$REMOTE_REPO_DIR"
mkdir -p "artifacts/$RUN_ID_VALUE"
if [[ -f final_model.pt ]]; then mv -f final_model.pt "artifacts/$RUN_ID_VALUE/final_model.pt"; fi
if [[ -f final_model.int8.ptz ]]; then mv -f final_model.int8.ptz "artifacts/$RUN_ID_VALUE/final_model.int8.ptz"; fi
if [[ -f final_model.int6.ptz ]]; then mv -f final_model.int6.ptz "artifacts/$RUN_ID_VALUE/final_model.int6.ptz"; fi
{
  echo "status=$RESULT_STATUS"
  echo "stage=submission_8xh100"
  echo "command_exit_code=$RESULT_REASON"
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
  local effective_extra_env
  local max_wallclock_seconds
  local run_id="submission8x_${slug}_$(date +%Y%m%d_%H%M%S)"
  local case_dir="$RESULT_DIR/$slug"
  local case_curve_file="$case_dir/validation_curve.tsv"
  local active_reference_curve_file="$SHARED_REFERENCE_CURVE_FILE"
  mkdir -p "$case_dir"

  if [[ ! -f "$active_reference_curve_file" ]]; then
    active_reference_curve_file="$QUEUE_REFERENCE_CURVE_FILE"
  fi

  effective_extra_env="$(augment_extra_env "$extra_env")"
  max_wallclock_seconds="$(resolve_env_value "$effective_extra_env" MAX_WALLCLOCK_SECONDS 600)"

  echo "=== submission candidate: $slug ==="
  echo "  branch: $branch"
  echo "  run_id: $run_id"
  echo "  extra_env: ${effective_extra_env:-<none>}"

  push_branch_if_needed "$branch"
  copy_runner_to_remote

  ssh_cmd "$TARGET" \
    "REMOTE_REPO_DIR=$(printf '%q' "$REMOTE_REPO_DIR") BRANCH_NAME=$(printf '%q' "$branch") RUN_ID_VALUE=$(printf '%q' "$run_id") STAGE_SLUG=$(printf '%q' "$slug") TRAIN_SCRIPT=$(printf '%q' "$train_script") EXTRA_ENV=$(printf '%q' "$effective_extra_env") bash -s" <<'EOF'
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
  early_stop_reason=""
  while (( $(date +%s) < deadline )); do
    log_tail="$(ssh_cmd "$TARGET" "test -f $(printf '%q' "$REMOTE_REPO_DIR/logs/$run_id.txt") && tail -n $EARLY_STOP_LOG_TAIL_LINES $(printf '%q' "$REMOTE_REPO_DIR/logs/$run_id.txt") || true")"
    if [[ "$log_tail" == *"final_int6_roundtrip_exact"* || "$log_tail" == *"final_int8_zlib_roundtrip_exact"* ]]; then
      final_detected=1
      break
    fi
    if [[ "$EARLY_STOP_ENABLE" == "1" && -f "$active_reference_curve_file" ]]; then
      early_stop_decision="$(should_early_stop "$log_tail" "$active_reference_curve_file" "$max_wallclock_seconds" "$EARLY_STOP_FRACTION" "$EARLY_STOP_MARGIN_BPB" "$EARLY_STOP_MIN_CHECKPOINTS" "$EARLY_STOP_MIN_IMPROVEMENT_BPB")"
      if [[ "$early_stop_decision" == EARLY_STOP* ]]; then
        early_stop_reason="$early_stop_decision"
        echo "early stopping $slug: $early_stop_reason"
        stop_remote_run "$train_script"
        break
      fi
    fi
    sleep "$POLL_SECONDS"
  done

  if [[ "$final_detected" != "1" && -z "$early_stop_reason" ]]; then
    echo "timed out waiting for final metric for $slug" >&2
    ssh_cmd "$TARGET" "tail -n 120 $(printf '%q' "$REMOTE_REPO_DIR/logs/$run_id.txt") 2>/dev/null || true" >"$case_dir/timeout_tail.txt" || true
    return 1
  fi

  if [[ -n "$early_stop_reason" ]]; then
    finalize_remote_run "$run_id" "$train_script" "EARLY_STOPPED" "$early_stop_reason"
  else
    finalize_remote_run "$run_id" "$train_script" "OK_MONITORED" "final_metric_detected"
  fi
  SSH_PORT="$SSH_PORT" bash "$ROOT/scripts/pull_remote_run_artifacts.sh" "$TARGET" "$run_id" "$case_dir"
  extract_validation_curve "$case_dir/logs/${run_id}.txt" "$case_curve_file"
  if [[ -f "$case_curve_file" && $(wc -l <"$case_curve_file") -gt 1 ]]; then
    if [[ ! -f "$SHARED_REFERENCE_CURVE_FILE" && "$QUEUE_REFERENCE_FALLBACK" == "1" && ! -f "$QUEUE_REFERENCE_CURVE_FILE" ]]; then
      cp "$case_curve_file" "$QUEUE_REFERENCE_CURVE_FILE"
      echo "captured queue fallback reference from $slug -> $QUEUE_REFERENCE_CURVE_FILE"
      if [[ "$PROMOTE_QUEUE_REFERENCE_TO_SHARED" == "1" ]]; then
        mkdir -p "$(dirname "$SHARED_REFERENCE_CURVE_FILE")"
        cp "$case_curve_file" "$SHARED_REFERENCE_CURVE_FILE"
        echo "promoted queue reference from $slug -> $SHARED_REFERENCE_CURVE_FILE"
      fi
    fi
  fi
}

bootstrap_remote

while IFS=$'\t' read -r slug branch train_script extra_env; do
  [[ -z "${slug:-}" ]] && continue
  [[ "${slug:0:1}" == "#" ]] && continue
  run_one "$slug" "$branch" "$train_script" "${extra_env:-}"
done <"$QUEUE_FILE"
