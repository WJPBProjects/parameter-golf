#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  cat <<'EOF'
Usage:
  bash scripts/run_remote_submission_8xh100.sh <experiment-slug> <train-script> [trainer args...]

Examples:
  bash scripts/run_remote_submission_8xh100.sh baseline train_gpt.py
  bash scripts/run_remote_submission_8xh100.sh merged-record-signalrush records/track_10min_16mb/2026-03-22_11L_EMA_GPTQ-lite_warmdown3500_QAT015_1.1233/train_gpt.py
EOF
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

EXPERIMENT_SLUG="$1"
TRAIN_SCRIPT="$2"
shift 2

if [[ ! -f "$TRAIN_SCRIPT" ]]; then
  echo "train script not found: $TRAIN_SCRIPT" >&2
  exit 1
fi

if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "nvidia-smi not found; this script must run on a CUDA machine" >&2
  exit 1
fi

gpu_count="$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l | tr -d ' ')"
if [[ "$gpu_count" != "8" ]]; then
  echo "expected 8 visible GPUs, found $gpu_count" >&2
  echo "this script is for true 8xH100 submission-style runs only" >&2
  exit 1
fi

export RUN_ID="${RUN_ID:-submission8x_${EXPERIMENT_SLUG}_$(date +%Y%m%d_%H%M%S)}"
export DATA_PATH="${DATA_PATH:-./data/datasets/fineweb10B_sp1024/}"
export TOKENIZER_PATH="${TOKENIZER_PATH:-./data/tokenizers/fineweb_1024_bpe.model}"
export VOCAB_SIZE="${VOCAB_SIZE:-1024}"
export SEED="${SEED:-1337}"
export VAL_LOSS_EVERY="${VAL_LOSS_EVERY:-0}"
export MAX_WALLCLOCK_SECONDS="${MAX_WALLCLOCK_SECONDS:-600}"
export NPROC_PER_NODE="${NPROC_PER_NODE:-8}"

if [[ "$NPROC_PER_NODE" != "8" ]]; then
  echo "NPROC_PER_NODE must be 8 for the submission runner; got $NPROC_PER_NODE" >&2
  exit 1
fi

mkdir -p logs artifacts

LOG_PATH="logs/${RUN_ID}.txt"
META_PATH="logs/${RUN_ID}.remote.meta.txt"
SUMMARY_PATH="logs/${RUN_ID}.summary.txt"
ARTIFACT_DIR="artifacts/${RUN_ID}"
MODEL_PT_SRC="final_model.pt"
MODEL_PTZ_INT8_SRC="final_model.int8.ptz"
MODEL_PTZ_INT6_SRC="final_model.int6.ptz"
STATUS="FAILED"

cat >"$META_PATH" <<EOF
stage=submission_8xh100
experiment_slug=$EXPERIMENT_SLUG
train_script=$TRAIN_SCRIPT
run_id=$RUN_ID
seed=$SEED
data_path=$DATA_PATH
tokenizer_path=$TOKENIZER_PATH
vocab_size=$VOCAB_SIZE
val_loss_every=$VAL_LOSS_EVERY
max_wallclock_seconds=$MAX_WALLCLOCK_SECONDS
nproc_per_node=$NPROC_PER_NODE
gpu_count_visible=$gpu_count
git_head=$(git rev-parse HEAD)
git_branch=$(git rev-parse --abbrev-ref HEAD)
hostname=$(hostname)
started_at_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo "Starting 8xH100 submission-style run:"
echo "  experiment: $EXPERIMENT_SLUG"
echo "  script:     $TRAIN_SCRIPT"
echo "  run_id:     $RUN_ID"
echo "  log:        $LOG_PATH"
echo "  meta:       $META_PATH"

set +e
torchrun --standalone --nproc_per_node="$NPROC_PER_NODE" "$TRAIN_SCRIPT" "$@" 2>&1 | tee "$LOG_PATH"
CMD_STATUS=${PIPESTATUS[0]}
set -e

if [[ $CMD_STATUS -eq 0 ]]; then
  STATUS="OK"
fi

{
  echo "status=$STATUS"
  echo "stage=submission_8xh100"
  echo "command_exit_code=$CMD_STATUS"
  echo "finished_at_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "log_path=$LOG_PATH"
  if [[ -f "$LOG_PATH" ]]; then
    grep -E "world_size:|final_int(6|8)_roundtrip|Serialized model int(6|8)\+zlib|Total submission size int(6|8)\+zlib|step_avg:|stopping_early:" "$LOG_PATH" | tail -n 20 || true
  else
    echo "log_missing=1"
  fi
} >"$SUMMARY_PATH"

mkdir -p "$ARTIFACT_DIR"
if [[ -f "$MODEL_PT_SRC" ]]; then
  mv -f "$MODEL_PT_SRC" "$ARTIFACT_DIR/final_model.pt"
  echo "artifact_model_pt=$ARTIFACT_DIR/final_model.pt" >>"$SUMMARY_PATH"
fi
if [[ -f "$MODEL_PTZ_INT8_SRC" ]]; then
  mv -f "$MODEL_PTZ_INT8_SRC" "$ARTIFACT_DIR/final_model.int8.ptz"
  echo "artifact_model_ptz=$ARTIFACT_DIR/final_model.int8.ptz" >>"$SUMMARY_PATH"
fi
if [[ -f "$MODEL_PTZ_INT6_SRC" ]]; then
  mv -f "$MODEL_PTZ_INT6_SRC" "$ARTIFACT_DIR/final_model.int6.ptz"
  echo "artifact_model_ptz=$ARTIFACT_DIR/final_model.int6.ptz" >>"$SUMMARY_PATH"
fi

cat "$SUMMARY_PATH"

exit "$CMD_STATUS"
