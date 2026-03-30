# Experiment: compile-safe-late-qat

This folder contains the experiment-local trainer copies for `codex/compile-safe-late-qat`.

This experiment is CUDA / `torch.compile` focused. On the local Mac, the meaningful
validation for the branch-local trainer copies is syntax-only (`py_compile`) unless a CUDA
runner is available.

Preferred files to edit:

- `experiments/compile-safe-late-qat/train_gpt.py`
- `experiments/compile-safe-late-qat/train_gpt_mlx.py`

Suggested local-screen command:

```bash
TRAIN_MLX_SCRIPT=experiments/compile-safe-late-qat/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
```

Suggested direct MLX command:

```bash
RUN_ID=compile-safe-late-qat_mlx ./.venv/bin/python experiments/compile-safe-late-qat/train_gpt_mlx.py
```

For this experiment, the PyTorch trainer is the one that matters for the actual idea:

```bash
QAT_ENABLED=1 LATE_QAT_THRESHOLD=0.15 RUN_ID=compile-safe-late-qat ./.venv/bin/python experiments/compile-safe-late-qat/train_gpt.py
```
