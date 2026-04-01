#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKTREES_ROOT="$(cd "$ROOT/.." && pwd)/$(basename "$ROOT")-worktrees"

wave="${1:-rerun-all}"
profile="${2:-confirm}"
run_tag="${RUN_TAG:-$(date +%Y%m%d_%H%M%S)}"
seed="${SEED:-1337}"
continue_on_error="${CONTINUE_ON_ERROR:-0}"
use_caffeinate="${USE_CAFFEINATE:-1}"

case "$profile" in
  screen)
    wrapper="scripts/run_local_screen_mlx.sh"
    profile_iterations="${ITERATIONS:-800}"
    profile_dev_val_max_batches="${DEV_VAL_MAX_BATCHES:-256}"
    profile_max_wallclock="${MAX_WALLCLOCK_SECONDS:-600}"
    ;;
  confirm)
    wrapper="scripts/run_local_confirm_mlx.sh"
    profile_iterations="${ITERATIONS:-4000}"
    profile_dev_val_max_batches="${DEV_VAL_MAX_BATCHES:-1024}"
    profile_max_wallclock="${MAX_WALLCLOCK_SECONDS:-5400}"
    ;;
  overnight)
    wrapper="scripts/run_local_overnight_mlx.sh"
    profile_iterations="${ITERATIONS:-12000}"
    profile_dev_val_max_batches="${DEV_VAL_MAX_BATCHES:-0}"
    profile_max_wallclock="${MAX_WALLCLOCK_SECONDS:-21600}"
    ;;
  *)
    echo "Unknown profile: $profile" >&2
    echo "Usage: $0 [rerun-all|rerun-tail|winner-focus|latest-pr-signal|latest-pr-tail|pr824-exploit|explore-lite] [screen|confirm|overnight]" >&2
    exit 1
    ;;
esac

profile_warmup_steps="${WARMUP_STEPS:-2}"
profile_train_batch_tokens="${TRAIN_BATCH_TOKENS:-8192}"
profile_val_batch_size="${VAL_BATCH_SIZE:-131072}"
profile_skip_final_int8_eval="${SKIP_FINAL_INT8_EVAL:-0}"
profile_mlx_eager_eval="${MLX_EAGER_EVAL:-0}"
profile_mlx_max_microbatch_tokens="${MLX_MAX_MICROBATCH_TOKENS:-16384}"

mkdir -p "$ROOT/logs"
wave_log="$ROOT/logs/${run_tag}_wave.txt"

require_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    echo "Missing directory: $dir" >&2
    echo "Restore experiment worktrees first:" >&2
    echo "  bash scripts/restore_experiment_worktrees.sh" >&2
    exit 1
  fi
}

run_case() {
  local label="$1"
  local dir="$2"
  local stderr_log="$ROOT/logs/${run_tag}_${label}.stderr.txt"
  shift 2
  require_dir "$dir"
  echo
  echo "==> [$label]"
  printf 'START [%s] profile=%s dir=%s\n' "$label" "$profile" "$dir" | tee -a "$wave_log"
  set +e
  (
    cd "$dir"
    local run_prefix=()
    if [[ "$use_caffeinate" == "1" ]] && command -v caffeinate >/dev/null 2>&1; then
      run_prefix=(caffeinate -dimsu)
    fi
    "${run_prefix[@]}" env \
        SEED="$seed" \
        RUN_ID="${run_tag}_${label}" \
        WARMUP_STEPS="$profile_warmup_steps" \
        ITERATIONS="$profile_iterations" \
        TRAIN_BATCH_TOKENS="$profile_train_batch_tokens" \
        VAL_BATCH_SIZE="$profile_val_batch_size" \
        DEV_VAL_MAX_BATCHES="$profile_dev_val_max_batches" \
        SKIP_FINAL_INT8_EVAL="$profile_skip_final_int8_eval" \
        MAX_WALLCLOCK_SECONDS="$profile_max_wallclock" \
        MLX_EAGER_EVAL="$profile_mlx_eager_eval" \
        MLX_MAX_MICROBATCH_TOKENS="$profile_mlx_max_microbatch_tokens" \
        "$@" \
        2> "$stderr_log"
  )
  status=$?
  set -e
  printf 'END [%s] status=%s\n' "$label" "$status" | tee -a "$wave_log"
  if [[ "$status" -ne 0 && "$continue_on_error" != "1" ]]; then
    exit "$status"
  fi
}

run_baseline() {
  run_case "baseline" "$ROOT" bash "$wrapper"
}

run_xsa_all() {
  run_case "xsa_all" "$WORKTREES_ROOT/xsa-all" \
    TRAIN_MLX_SCRIPT=experiments/xsa-all/train_gpt_mlx.py \
    XSA_LAST_N=9 \
    bash "$wrapper"
}

run_leakyrelu() {
  run_case "leakyrelu" "$WORKTREES_ROOT/leakyrelu-slope-sweep" \
    TRAIN_MLX_SCRIPT=experiments/leakyrelu-slope-sweep/train_gpt_mlx.py \
    LEAKY_RELU_NEGATIVE_SLOPE=0.05 \
    bash "$wrapper"
}

run_pr824_mimic() {
  run_case "pr824_mimic" "$WORKTREES_ROOT/pr824-mimic-gatedattn-valueresid" \
    TRAIN_MLX_SCRIPT=experiments/pr824-mimic-gatedattn-valueresid/train_gpt_mlx.py \
    bash "$wrapper"
}

run_qkgain5_pr1217() {
  run_case "qkgain5_pr1217" "$WORKTREES_ROOT/qkgain5-pr1217" \
    TRAIN_MLX_SCRIPT=experiments/qkgain5-pr1217/train_gpt_mlx.py \
    QK_GAIN_INIT=5.0 \
    bash "$wrapper"
}

run_gptq_calib_validation() {
  run_case "gptq_calib_validation" "$WORKTREES_ROOT/gptq-self-calibration" \
    TRAIN_MLX_SCRIPT=experiments/gptq-self-calibration/train_gpt_mlx.py \
    TEMP_SCALING=1 \
    CALIBRATION_SOURCE=validation \
    CALIBRATION_TOKENS=2048 \
    bash "$wrapper"
}

run_gptq_calib_self_generated() {
  run_case "gptq_calib_self_generated" "$WORKTREES_ROOT/gptq-self-calibration" \
    TRAIN_MLX_SCRIPT=experiments/gptq-self-calibration/train_gpt_mlx.py \
    TEMP_SCALING=1 \
    CALIBRATION_SOURCE=self_generated \
    CALIBRATION_TOKENS=2048 \
    CALIBRATION_PROMPT_TOKENS=64 \
    bash "$wrapper"
}

run_gptq_calib_random_tokens() {
  run_case "gptq_calib_random_tokens" "$WORKTREES_ROOT/gptq-self-calibration" \
    TRAIN_MLX_SCRIPT=experiments/gptq-self-calibration/train_gpt_mlx.py \
    TEMP_SCALING=1 \
    CALIBRATION_SOURCE=random_tokens \
    CALIBRATION_TOKENS=2048 \
    bash "$wrapper"
}

run_selective_prune() {
  run_case "selective_post_gptq_pruning" "$WORKTREES_ROOT/selective-post-gptq-pruning" \
    TRAIN_MLX_SCRIPT=experiments/selective-post-gptq-pruning/train_gpt_mlx.py \
    POST_GPTQ_PRUNE_FRACTION=0.02 \
    POST_GPTQ_PRUNE_MIN_NUMEL=16384 \
    bash "$wrapper"
}

run_rope_lnscale() {
  run_case "rope_lnscale" "$WORKTREES_ROOT/rope-lnscale-grid" \
    TRAIN_MLX_SCRIPT=experiments/rope-lnscale-grid/train_gpt_mlx.py \
    ROPE_DIM=16 \
    LN_SCALE_INIT=inv_sqrt \
    bash "$wrapper"
}

run_splineconv() {
  run_case "splineconv_hybrid" "$WORKTREES_ROOT/splineconv-hybrid" \
    TRAIN_MLX_SCRIPT=experiments/splineconv-hybrid/train_gpt_mlx.py \
    SPLINE_LAYER_MODE=decoder \
    SPLINE_RADIUS=4 \
    SPLINE_NUM_KNOTS=4 \
    bash "$wrapper"
}

run_parallel_residuals_pr1204() {
  run_case "parallel_residuals_pr1204" "$WORKTREES_ROOT/parallel-residuals-pr1204" \
    TRAIN_MLX_SCRIPT=experiments/parallel-residuals-pr1204/train_gpt_mlx.py \
    PARALLEL_RESIDUAL=1 \
    PARALLEL_START_LAYER=6 \
    bash "$wrapper"
}

run_pr824_value_residual_only() {
  run_case "pr824_value_residual_only" "$WORKTREES_ROOT/pr824-value-residual-only" \
    TRAIN_MLX_SCRIPT=experiments/pr824-value-residual-only/train_gpt_mlx.py \
    bash "$wrapper"
}

run_pr824_attn_gate_only() {
  run_case "pr824_attn_gate_only" "$WORKTREES_ROOT/pr824-attn-gate-only" \
    TRAIN_MLX_SCRIPT=experiments/pr824-attn-gate-only/train_gpt_mlx.py \
    bash "$wrapper"
}

run_pr824_qkgain5() {
  run_case "pr824_qkgain5" "$WORKTREES_ROOT/pr824-qkgain5" \
    TRAIN_MLX_SCRIPT=experiments/pr824-qkgain5/train_gpt_mlx.py \
    bash "$wrapper"
}

run_pr824_xsa4() {
  run_case "pr824_xsa4" "$WORKTREES_ROOT/pr824-xsa4" \
    TRAIN_MLX_SCRIPT=experiments/pr824-xsa4/train_gpt_mlx.py \
    bash "$wrapper"
}

run_hyperconnection_lite() {
  run_case "hyperconnection_lite" "$WORKTREES_ROOT/hyperconnection-lite" \
    TRAIN_MLX_SCRIPT=experiments/hyperconnection-lite/train_gpt_mlx.py \
    bash "$wrapper"
}

run_kgiir_lite() {
  run_case "kgiir_lite" "$WORKTREES_ROOT/kgiir-lite" \
    TRAIN_MLX_SCRIPT=experiments/kgiir-lite/train_gpt_mlx.py \
    bash "$wrapper"
}

case "$wave" in
  rerun-all)
    run_baseline
    run_xsa_all
    run_leakyrelu
    run_pr824_mimic
    run_gptq_calib_validation
    run_gptq_calib_self_generated
    run_gptq_calib_random_tokens
    run_selective_prune
    run_rope_lnscale
    run_splineconv
    ;;
  rerun-tail)
    run_xsa_all
    run_leakyrelu
    run_pr824_mimic
    run_gptq_calib_validation
    run_gptq_calib_self_generated
    run_gptq_calib_random_tokens
    run_selective_prune
    run_rope_lnscale
    run_splineconv
    ;;
  winner-focus)
    run_baseline
    run_pr824_mimic
    run_xsa_all
    ;;
  latest-pr-signal)
    run_baseline
    run_pr824_mimic
    run_qkgain5_pr1217
    run_parallel_residuals_pr1204
    ;;
  latest-pr-tail)
    run_pr824_mimic
    run_qkgain5_pr1217
    run_parallel_residuals_pr1204
    ;;
  pr824-exploit)
    run_baseline
    run_pr824_mimic
    run_pr824_value_residual_only
    run_pr824_attn_gate_only
    run_pr824_qkgain5
    run_pr824_xsa4
    ;;
  explore-lite)
    run_baseline
    run_hyperconnection_lite
    run_kgiir_lite
    ;;
  *)
    echo "Unknown wave: $wave" >&2
    echo "Usage: $0 [rerun-all|rerun-tail|winner-focus|latest-pr-signal|latest-pr-tail|pr824-exploit|explore-lite] [screen|confirm|overnight]" >&2
    exit 1
    ;;
esac
