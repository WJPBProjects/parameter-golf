# Experiment: selective-post-gptq-pruning

This folder contains the experiment-local trainer copies for `codex/selective-post-gptq-pruning`.

Preferred files to edit:

- `experiments/selective-post-gptq-pruning/train_gpt.py`
- `experiments/selective-post-gptq-pruning/train_gpt_mlx.py`

Suggested local-screen command:

```bash
TRAIN_MLX_SCRIPT=experiments/selective-post-gptq-pruning/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
```

Suggested direct MLX command:

```bash
POST_GPTQ_PRUNE_FRACTION=0.02 POST_GPTQ_PRUNE_MIN_NUMEL=16384 RUN_ID=selective-post-gptq-pruning_mlx ./.venv/bin/python experiments/selective-post-gptq-pruning/train_gpt_mlx.py
```
