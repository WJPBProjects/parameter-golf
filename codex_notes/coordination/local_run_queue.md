# Local Run Queue

Use this file as the simplest sequential run order for the current local Mac screening wave.

Baseline to beat:

- `codex_notes/coordination/baseline_benchmarks.md`
- Current local MLX baseline post-quant `val_bpb`: `3.85822586`

Already screened:

- `xsa-all`: locally better and already marked `READY` for remote
- `pr824-mimic-gatedattn-valueresid`: locally better on the same screen harness, with `val_bpb 2.2407` vs baseline `2.2674`
- `leakyrelu-slope-sweep`: plumbing tested, currently `HOLD`

## Recommended next local sequence

1. Selective post-GPTQ pruning

```bash
cd /Users/wulfie/code/parameter-golf-worktrees/selective-post-gptq-pruning
source .venv/bin/activate
TRAIN_MLX_SCRIPT=experiments/selective-post-gptq-pruning/train_gpt_mlx.py \
POST_GPTQ_PRUNE_FRACTION=0.02 \
POST_GPTQ_PRUNE_MIN_NUMEL=16384 \
bash scripts/run_local_screen_mlx.sh
```

2. GPTQ self calibration, `validation`

```bash
cd /Users/wulfie/code/parameter-golf-worktrees/gptq-self-calibration
source .venv/bin/activate
TEMP_SCALING=1 \
CALIBRATION_SOURCE=validation \
CALIBRATION_TOKENS=2048 \
SKIP_FINAL_INT8_EVAL=0 \
RUN_ID=gptq-self-calibration_validation \
./.venv/bin/python experiments/gptq-self-calibration/train_gpt_mlx.py
```

3. GPTQ self calibration, `self_generated`

```bash
cd /Users/wulfie/code/parameter-golf-worktrees/gptq-self-calibration
source .venv/bin/activate
TEMP_SCALING=1 \
CALIBRATION_SOURCE=self_generated \
CALIBRATION_TOKENS=2048 \
CALIBRATION_PROMPT_TOKENS=64 \
SKIP_FINAL_INT8_EVAL=0 \
RUN_ID=gptq-self-calibration_self_generated \
./.venv/bin/python experiments/gptq-self-calibration/train_gpt_mlx.py
```

4. GPTQ self calibration, `random_tokens`

```bash
cd /Users/wulfie/code/parameter-golf-worktrees/gptq-self-calibration
source .venv/bin/activate
TEMP_SCALING=1 \
CALIBRATION_SOURCE=random_tokens \
CALIBRATION_TOKENS=2048 \
SKIP_FINAL_INT8_EVAL=0 \
RUN_ID=gptq-self-calibration_random_tokens \
./.venv/bin/python experiments/gptq-self-calibration/train_gpt_mlx.py
```

5. RoPE + LN-scale grid, first point

```bash
cd /Users/wulfie/code/parameter-golf-worktrees/rope-lnscale-grid
source .venv/bin/activate
ROPE_DIM=16 \
LN_SCALE_INIT=inv_sqrt \
TRAIN_MLX_SCRIPT=experiments/rope-lnscale-grid/train_gpt_mlx.py \
bash scripts/run_local_screen_mlx.sh
```

6. SplineConv hybrid

```bash
cd /Users/wulfie/code/parameter-golf-worktrees/splineconv-hybrid
source .venv/bin/activate
TRAIN_MLX_SCRIPT=experiments/splineconv-hybrid/train_gpt_mlx.py \
SPLINE_LAYER_MODE=decoder \
SPLINE_RADIUS=4 \
SPLINE_NUM_KNOTS=4 \
MLX_EAGER_EVAL=0 \
MLX_MAX_MICROBATCH_TOKENS=16384 \
DEV_VAL_MAX_BATCHES=128 \
SKIP_FINAL_INT8_EVAL=1 \
bash scripts/run_local_screen_mlx.sh
```

## Skip locally for now

Compile-safe Late-QAT is prepared in:

- `/Users/wulfie/code/parameter-golf-worktrees/compile-safe-late-qat`

But it should be treated as remote/CUDA-focused rather than part of the local MLX queue. When it is time to run it remotely, start from the experiment note in:

- `codex_notes/scratchpads/compile-safe-late-qat.md`
