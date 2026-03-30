# Experiment: rope-lnscale-grid

This folder contains the experiment-local trainer copies for `codex/rope-lnscale-grid`.

Preferred files to edit:

- `experiments/rope-lnscale-grid/train_gpt.py`
- `experiments/rope-lnscale-grid/train_gpt_mlx.py`

Suggested local-screen command:

```bash
TRAIN_MLX_SCRIPT=experiments/rope-lnscale-grid/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
```

Suggested sweep starting point:

```bash
ROPE_DIM=16 LN_SCALE_INIT=inv_sqrt TRAIN_MLX_SCRIPT=experiments/rope-lnscale-grid/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
```

Useful grid values:

- `ROPE_DIM`: `8`, `16`, `24`, `32` (or `0` for full head_dim)
- `LN_SCALE_INIT`: `ones`, `inv_sqrt`, `inv_linear`

Suggested direct MLX command:

```bash
RUN_ID=rope-lnscale-grid_mlx ./.venv/bin/python experiments/rope-lnscale-grid/train_gpt_mlx.py
```
