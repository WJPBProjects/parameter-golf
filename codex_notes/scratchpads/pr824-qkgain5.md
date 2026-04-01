# Experiment

- Name: `pr824-qkgain5`
- Status: `TODO`
- Owner: `main-agent`
- Branch: `codex/pr824-qkgain5`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/pr824-qkgain5`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/pr824-qkgain5/train_gpt_mlx.py`

## Hypothesis

- If the April-1 `QK_GAIN=5.0` public frontier signal composes with the verified PR824-family winner, this stacked variant should beat the plain PR824 mimic locally.

## Scope

- Local screen command(s):
  - `cd /Users/wulfie/code/parameter-golf-worktrees/pr824-qkgain5 && TRAIN_MLX_SCRIPT=experiments/pr824-qkgain5/train_gpt_mlx.py bash scripts/run_local_confirm_mlx.sh`

## Next step

- Run it in the `pr824-exploit` confirm wave.
