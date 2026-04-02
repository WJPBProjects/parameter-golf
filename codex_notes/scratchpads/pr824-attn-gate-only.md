# Experiment

- Name: `pr824-attn-gate-only`
- Status: `PASS`
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

- Result from `pr824_exploit_20260402`:
  - log: `/Users/wulfie/code/parameter-golf-worktrees/pr824-attn-gate-only/logs/pr824_exploit_20260402_pr824_attn_gate_only.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.68098646`
  - fresh baseline: `1.69601453`
  - value-residual-only: `1.67099164`
  - full PR824 mimic: `1.66814857`
  - `step_avg: 322.27ms`
  - `serialized_model_int8_zlib: 15104730 bytes`
- Interpretation:
  - Attention gating alone is a real but smaller positive effect.
  - The branch is clearly weaker than value-residual-only, so the main research bet should stay on value-path variants.
