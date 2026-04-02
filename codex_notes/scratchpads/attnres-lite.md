# Experiment

- Name: `attnres-lite`
- Status: `TODO`
- Owner: `main-agent`
- Branch: `codex/attnres-lite`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/attnres-lite`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/attnres-lite/train_gpt_mlx.py`

## Hypothesis

- A tiny learned 2-source mixer between the current residual stream and the skip source in the last 4 layers may improve on the baseline’s fixed skip injection with very little parameter cost.

## Scope

- Local screen command(s):
  - `cd /Users/wulfie/code/parameter-golf-worktrees/attnres-lite && TRAIN_MLX_SCRIPT=experiments/attnres-lite/train_gpt_mlx.py bash scripts/run_local_confirm_mlx.sh`

## Next step

- Run in `explore-lite` after the exploit wave.
