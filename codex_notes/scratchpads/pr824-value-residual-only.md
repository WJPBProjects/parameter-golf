# Experiment

- Name: `pr824-value-residual-only`
- Status: `PASS`
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

- Result from `pr824_exploit_20260402`:
  - log: `/Users/wulfie/code/parameter-golf-worktrees/pr824-value-residual-only/logs/pr824_exploit_20260402_pr824_value_residual_only.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.67099164`
  - fresh baseline: `1.69601453`
  - full PR824 mimic in same wave: `1.66814857`
  - `step_avg: 324.12ms`
  - `serialized_model_int8_zlib: 15395185 bytes`
- Interpretation:
  - This ablation keeps almost all of the full PR824 mimic gain.
  - Value residual is therefore the dominant part of the PR824 stack.
- Next step:
  - Keep this branch as the clean control for future value-path mutations such as `pr824-value-embedding-lite`.
