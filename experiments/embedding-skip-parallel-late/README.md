# Experiment: embedding-skip-parallel-late

This folder contains the experiment-local trainer copies for `codex/embedding-skip-parallel-late`.

Preferred files to edit:

- `experiments/embedding-skip-parallel-late/train_gpt.py`
- `experiments/embedding-skip-parallel-late/train_gpt_mlx.py`

Suggested local-screen command:

```bash
TRAIN_MLX_SCRIPT=experiments/embedding-skip-parallel-late/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
```

Suggested direct MLX command:

```bash
RUN_ID=embedding-skip-parallel-late_mlx ./.venv/bin/python experiments/embedding-skip-parallel-late/train_gpt_mlx.py
```
