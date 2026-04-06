# Experiment: late-value-scale-qk5

This folder contains the experiment-local trainer copies for `codex/late-value-scale-qk5`.

Preferred files to edit:

- `experiments/late-value-scale-qk5/train_gpt.py`
- `experiments/late-value-scale-qk5/train_gpt_mlx.py`

Suggested local-screen command:

```bash
TRAIN_MLX_SCRIPT=experiments/late-value-scale-qk5/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
```

Suggested direct MLX command:

```bash
RUN_ID=late-value-scale-qk5_mlx ./.venv/bin/python experiments/late-value-scale-qk5/train_gpt_mlx.py
```
