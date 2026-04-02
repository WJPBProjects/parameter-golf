# Experiment

- Name: `attnres-lite`
- Status: `PASS`
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

- Result from `explore_lite_20260402`:
  - log: `/Users/wulfie/code/parameter-golf-worktrees/attnres-lite/logs/explore_lite_20260402_attnres_lite.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.68501439`
  - fresh baseline: `1.69239991`
  - `step_avg: 315.04ms`
  - `serialized_model_int8_zlib: 15311780 bytes`
- Interpretation:
  - Modest but real local win with a small speed and size cost.
  - This is weaker than PR824/value-residual-only, but strong enough to justify one stack experiment.
- Next step:
  - Prepare `pr824 + attnres-lite` or `value-residual-only + attnres-lite` once the current queue drains.
