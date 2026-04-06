# Parallel Residuals PR1204

- Branch: `codex/parallel-residuals-pr1204`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/parallel-residuals-pr1204`
- Trainer paths:
  - `experiments/parallel-residuals-pr1204/train_gpt.py`
  - `experiments/parallel-residuals-pr1204/train_gpt_mlx.py`

## Hypothesis

Add a lightweight parallel residual stream split in deeper layers and pair it with the already-supported `QK_GAIN_INIT=5.0` geometry tweak. This is not a full reproduction of the public recurrence frontier, but it tests a clean neural-path ingredient that should be legal and remote-runnable.

## Current status

- MLX confirm command running/ran:

```bash
QK_GAIN_INIT=5.0 \
TRAIN_MLX_SCRIPT=experiments/parallel-residuals-pr1204/train_gpt_mlx.py \
RUN_ID=parallelres_qkgain5_confirm_$(date +%Y%m%d_%H%M%S) \
bash scripts/run_local_confirm_mlx.sh
```

- CUDA `train_gpt.py` now has the same branch-local parallel residual mechanism so it can be used by the `8xH100` remote runner.
- Suggested remote extra env: `QK_GAIN_INIT=5.0 PARALLEL_RESIDUAL=1 PARALLEL_START_LAYER=6 VAL_LOSS_EVERY=1500`

## Decision

Remote candidate once the shared `8xH100` reference curve is available.
