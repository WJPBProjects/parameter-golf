#!/usr/bin/env bash

set -euo pipefail

# Stage 3: remote validation on a cheaper CUDA machine, usually 1xH100.
# This is the pre-submission remote check, not the final 8xH100 run.

if [[ $# -lt 2 ]]; then
  cat <<'EOF'
Usage:
  bash scripts/run_remote_experiment.sh <experiment-slug> <train-script> [trainer args...]

Examples:
  bash scripts/run_remote_experiment.sh baseline train_gpt.py
  bash scripts/run_remote_experiment.sh merged-record-signalrush records/track_10min_16mb/2026-03-22_11L_EMA_GPTQ-lite_warmdown3500_QAT015_1.1233/train_gpt.py
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

export RUN_ID="${RUN_ID:-remote_${EXPERIMENT_SLUG}_$(date +%Y%m%d_%H%M%S)}"
export DATA_PATH="${DATA_PATH:-./data/datasets/fineweb10B_sp1024/}"
export TOKENIZER_PATH="${TOKENIZER_PATH:-./data/tokenizers/fineweb_1024_bpe.model}"
export VOCAB_SIZE="${VOCAB_SIZE:-1024}"
export SEED="${SEED:-1337}"
export VAL_LOSS_EVERY="${VAL_LOSS_EVERY:-0}"
export MAX_WALLCLOCK_SECONDS="${MAX_WALLCLOCK_SECONDS:-600}"
NPROC_PER_NODE="${NPROC_PER_NODE:-1}"

mkdir -p logs
mkdir -p artifacts

LOG_PATH="logs/${RUN_ID}.txt"
META_PATH="logs/${RUN_ID}.remote.meta.txt"
SUMMARY_PATH="logs/${RUN_ID}.summary.txt"
ARTIFACT_DIR="artifacts/${RUN_ID}"
MODEL_PT_SRC="final_model.pt"
MODEL_PTZ_SRC="final_model.int8.ptz"
MODEL_PT_DST="${ARTIFACT_DIR}/final_model.pt"
MODEL_PTZ_DST="${ARTIFACT_DIR}/final_model.int8.ptz"
STATUS="FAILED"

cat >"$META_PATH" <<EOF
stage=remote_validation
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
git_head=$(git rev-parse HEAD)
git_branch=$(git rev-parse --abbrev-ref HEAD)
hostname=$(hostname)
started_at_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo "Starting remote run:"
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
  echo "stage=remote_validation"
  echo "command_exit_code=$CMD_STATUS"
  echo "finished_at_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "log_path=$LOG_PATH"
  if [[ -f "$LOG_PATH" ]]; then
    grep -E "final_int8_zlib_roundtrip|serialized_model_int8_zlib|step_avg:" "$LOG_PATH" | tail -n 12 || true
  else
    echo "log_missing=1"
  fi
} >"$SUMMARY_PATH"

mkdir -p "$ARTIFACT_DIR"
if [[ -f "$MODEL_PT_SRC" ]]; then
  mv -f "$MODEL_PT_SRC" "$MODEL_PT_DST"
  echo "artifact_model_pt=$MODEL_PT_DST" >>"$SUMMARY_PATH"
fi
if [[ -f "$MODEL_PTZ_SRC" ]]; then
  mv -f "$MODEL_PTZ_SRC" "$MODEL_PTZ_DST"
  echo "artifact_model_ptz=$MODEL_PTZ_DST" >>"$SUMMARY_PATH"
fi

cat "$SUMMARY_PATH"

exit "$CMD_STATUS"
