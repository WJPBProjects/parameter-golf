# Experiment: late-value-embed-qk5

This folder contains the experiment-local trainer copies for `codex/late-value-embed-qk5`.

Preferred files to edit:

- `experiments/late-value-embed-qk5/train_gpt.py`
- `experiments/late-value-embed-qk5/train_gpt_mlx.py`

Suggested local-screen command:

```bash
TRAIN_MLX_SCRIPT=experiments/late-value-embed-qk5/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
```

Suggested direct MLX command:

```bash
RUN_ID=late-value-embed-qk5_mlx ./.venv/bin/python experiments/late-value-embed-qk5/train_gpt_mlx.py
```

Suggested remote command:

```bash
VE_ENABLED=1 VE_DIM=128 VE_LAYERS=7,8 QK_GAIN_INIT=5.0 \
RUN_ID=late-value-embed-qk5 ./.venv/bin/python experiments/late-value-embed-qk5/train_gpt.py
```
