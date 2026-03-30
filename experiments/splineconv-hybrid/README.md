# Experiment: splineconv-hybrid

This folder contains the experiment-local trainer copies for `codex/splineconv-hybrid`.

Preferred files to edit:

- `experiments/splineconv-hybrid/train_gpt.py`
- `experiments/splineconv-hybrid/train_gpt_mlx.py`

Suggested local-screen command:

```bash
TRAIN_MLX_SCRIPT=experiments/splineconv-hybrid/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
```

Suggested direct MLX command:

```bash
RUN_ID=splineconv-hybrid_mlx ./.venv/bin/python experiments/splineconv-hybrid/train_gpt_mlx.py
```

Current spline-hybrid defaults for the first sequential screen:

- `SPLINE_LAYER_MODE=decoder`
- `SPLINE_RADIUS=4`
- `SPLINE_NUM_KNOTS=4`

Recommended local-screen invocation:

```bash
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
