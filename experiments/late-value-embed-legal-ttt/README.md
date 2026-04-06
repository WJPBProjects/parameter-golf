# Experiment: late-value-embed-legal-ttt

This folder contains the experiment-local trainer copies for `codex/late-value-embed-legal-ttt`.

Preferred files to edit:

- `experiments/late-value-embed-legal-ttt/train_gpt.py`
- `experiments/late-value-embed-legal-ttt/train_gpt_mlx.py`

Suggested local-screen command:

```bash
TRAIN_MLX_SCRIPT=experiments/late-value-embed-legal-ttt/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
```

Suggested direct MLX command:

```bash
RUN_ID=late-value-embed-legal-ttt_mlx ./.venv/bin/python experiments/late-value-embed-legal-ttt/train_gpt_mlx.py
```
