# Experiment: parallel-residuals-pr1204

This folder contains the experiment-local trainer copies for `codex/parallel-residuals-pr1204`.

Preferred files to edit:

- `experiments/parallel-residuals-pr1204/train_gpt.py`
- `experiments/parallel-residuals-pr1204/train_gpt_mlx.py`

Suggested local-screen command:

```bash
TRAIN_MLX_SCRIPT=experiments/parallel-residuals-pr1204/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
```

Suggested direct MLX command:

```bash
RUN_ID=parallel-residuals-pr1204_mlx ./.venv/bin/python experiments/parallel-residuals-pr1204/train_gpt_mlx.py
```
