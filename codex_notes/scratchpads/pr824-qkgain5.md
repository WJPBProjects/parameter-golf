# Experiment

- Name: `pr824-qkgain5`
- Status: `BLOCKED`
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

- This branch is currently misconfigured.
  - During `pr824_exploit_20260402`, the trainer log did not show the PR824 mimic flags, and a direct source check only found `QK_GAIN_INIT=5.0` without the PR824 value-residual / attn-gate implementation.
  - The run was manually killed.
- Required fix before rerun:
  - rebuild `experiments/pr824-qkgain5/train_gpt_mlx.py` from the PR824 mimic trainer and then set `QK_GAIN_INIT=5.0` on top of that stack.
  - update the runner so this case passes `QK_GAIN_INIT=5.0` explicitly.
