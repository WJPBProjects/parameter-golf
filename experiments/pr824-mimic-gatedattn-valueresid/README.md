# Experiment: pr824-mimic-gatedattn-valueresid

This folder contains the experiment-local trainer copies for `codex/pr824-mimic-gatedattn-valueresid`.

It is a local-stack approximation of the strongest current transformer-style PR:

- [PR #824](https://github.com/openai/parameter-golf/pull/824)

This branch does **not** try to recreate the full PR stack. Instead it starts from the local `xsa-all` code path and adds the two architectural deltas that map cleanly onto the current trainer:

- `attn_gate`: per-head FP32 gate on attention outputs
- `lambda_v`: per-block FP32 scalar injecting `x0` into the residual stream

What it intentionally does **not** include:

- `HedgeMixer`
- `BigramHash4K`
- legal score-first TTT

Preferred files to edit:

- `experiments/pr824-mimic-gatedattn-valueresid/train_gpt.py`
- `experiments/pr824-mimic-gatedattn-valueresid/train_gpt_mlx.py`

Local-screen command used:

```bash
RUN_ID=pr824_mimic_local_screen \
TRAIN_MLX_SCRIPT=experiments/pr824-mimic-gatedattn-valueresid/train_gpt_mlx.py \
bash scripts/run_local_screen_mlx.sh
```

Current result on the shared local-screen harness:

- baseline: `val_bpb 2.2674`, `277.01ms/step`, `12,291,845 bytes`
- mimic: `val_bpb 2.2407`, `291.44ms/step`, `12,496,386 bytes`

So this branch gives a real positive directional signal on the Mac, even though it is only a partial PR mimic.
