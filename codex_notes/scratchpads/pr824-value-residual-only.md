# Experiment

- Name: `pr824-value-residual-only`
- Status: `TODO`
- Owner: `main-agent`
- Branch: `codex/pr824-value-residual-only`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/pr824-value-residual-only`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/pr824-value-residual-only/train_gpt_mlx.py`

## Hypothesis

- If value residual is the main driver of the PR824-family win, this ablation should retain most of the gain even with attention gating removed.

## Scope

- Local screen command(s):
  - `cd /Users/wulfie/code/parameter-golf-worktrees/pr824-value-residual-only && TRAIN_MLX_SCRIPT=experiments/pr824-value-residual-only/train_gpt_mlx.py bash scripts/run_local_confirm_mlx.sh`

## Next step

- Run it in the `pr824-exploit` confirm wave.
