# Experiment: gptq-self-calibration

This folder contains the experiment-local trainer copies for `codex/gptq-self-calibration`.

Preferred files to edit:

- `experiments/gptq-self-calibration/train_gpt.py`
- `experiments/gptq-self-calibration/train_gpt_mlx.py`

Suggested local-screen command:

```bash
TRAIN_MLX_SCRIPT=experiments/gptq-self-calibration/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
```

Suggested direct MLX command:

```bash
RUN_ID=gptq-self-calibration_mlx ./.venv/bin/python experiments/gptq-self-calibration/train_gpt_mlx.py
```

Suggested calibration-source comparison commands:

```bash
TEMP_SCALING=1 \
CALIBRATION_SOURCE=validation \
CALIBRATION_TOKENS=2048 \
SKIP_FINAL_INT8_EVAL=0 \
RUN_ID=gptq-self-calibration_validation ./.venv/bin/python experiments/gptq-self-calibration/train_gpt_mlx.py

TEMP_SCALING=1 \
CALIBRATION_SOURCE=self_generated \
CALIBRATION_TOKENS=2048 \
CALIBRATION_PROMPT_TOKENS=64 \
SKIP_FINAL_INT8_EVAL=0 \
RUN_ID=gptq-self-calibration_self_generated ./.venv/bin/python experiments/gptq-self-calibration/train_gpt_mlx.py

TEMP_SCALING=1 \
CALIBRATION_SOURCE=random_tokens \
CALIBRATION_TOKENS=2048 \
SKIP_FINAL_INT8_EVAL=0 \
RUN_ID=gptq-self-calibration_random_tokens ./.venv/bin/python experiments/gptq-self-calibration/train_gpt_mlx.py
```
