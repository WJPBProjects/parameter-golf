# Experiment

- Name: `pr824-attn-gate-only`
- Status: `TODO`
- Owner: `main-agent`
- Branch: `codex/pr824-attn-gate-only`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/pr824-attn-gate-only`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/pr824-attn-gate-only/train_gpt_mlx.py`

## Hypothesis

- If the PR824-family gain is mostly coming from value residual, this attn-gate-only ablation should be weaker than the full mimic and likely weaker than the value-residual-only ablation.

## Scope

- Local screen command(s):
  - `cd /Users/wulfie/code/parameter-golf-worktrees/pr824-attn-gate-only && TRAIN_MLX_SCRIPT=experiments/pr824-attn-gate-only/train_gpt_mlx.py bash scripts/run_local_confirm_mlx.sh`

## Next step

- Run it in the `pr824-exploit` confirm wave.
