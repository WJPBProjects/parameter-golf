#!/usr/bin/env bash

set -euo pipefail

# Stage 2: stronger local confirmation on MLX. This is intentionally longer than
# the true remote cap so the laptop can produce a cleaner directional signal.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export RUN_ID="${RUN_ID:-local_confirm_$(date +%Y%m%d_%H%M%S)}"
export WARMUP_STEPS="${WARMUP_STEPS:-2}"
export ITERATIONS="${ITERATIONS:-4000}"
export TRAIN_BATCH_TOKENS="${TRAIN_BATCH_TOKENS:-8192}"
export VAL_LOSS_EVERY="${VAL_LOSS_EVERY:-0}"
export VAL_BATCH_SIZE="${VAL_BATCH_SIZE:-131072}"
export DEV_VAL_MAX_BATCHES="${DEV_VAL_MAX_BATCHES:-1024}"
export SKIP_FINAL_INT8_EVAL="${SKIP_FINAL_INT8_EVAL:-0}"
export MLX_EAGER_EVAL="${MLX_EAGER_EVAL:-0}"
export MLX_MAX_MICROBATCH_TOKENS="${MLX_MAX_MICROBATCH_TOKENS:-16384}"
export MAX_WALLCLOCK_SECONDS="${MAX_WALLCLOCK_SECONDS:-5400}"

SCRIPT_PATH="${TRAIN_MLX_SCRIPT:-train_gpt_mlx.py}"

exec ./.venv/bin/python "$SCRIPT_PATH" "$@"
