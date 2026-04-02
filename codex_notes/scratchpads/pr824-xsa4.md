# Experiment

- Name: `pr824-xsa4`
- Status: `TODO`
- Owner: `main-agent`
- Branch: `codex/pr824-xsa4`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/pr824-xsa4`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/pr824-xsa4/train_gpt_mlx.py`

## Hypothesis

- The full PR824 mimic may not need `XSA_LAST_N=6`; a narrower `XSA_LAST_N=4` could preserve most of the quality gain with less overhead.

## Scope

- Local screen command(s):
  - `cd /Users/wulfie/code/parameter-golf-worktrees/pr824-xsa4 && TRAIN_MLX_SCRIPT=experiments/pr824-xsa4/train_gpt_mlx.py bash scripts/run_local_confirm_mlx.sh`

## Next step

- The first `pr824_exploit_20260402` attempt was manually killed because the branch trainer still defaulted to `XSA_LAST_N=6`.
- That bug is now repaired in the branch worktree:
  - `experiments/pr824-xsa4/train_gpt_mlx.py` now defaults `XSA_LAST_N=4`
  - the PR824 mimic attn-gate/value-residual wiring and startup logging remain intact
  - `python -m py_compile` passed
- Rerun this branch in the `pr824-fixups` wave and verify the startup log prints `xsa_last_n:4`.
