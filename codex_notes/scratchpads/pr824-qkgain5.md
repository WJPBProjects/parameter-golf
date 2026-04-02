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

- The first `pr824_exploit_20260402` attempt was manually killed because the branch trainer was only standalone `QK_GAIN=5.0`, not PR824 + QK gain.
- That bug is now repaired in the branch worktree:
  - `experiments/pr824-qkgain5/train_gpt_mlx.py` was rebuilt from the PR824 mimic trainer
  - `QK_GAIN_INIT` now defaults to `5.0`
  - `xsa_last_n=6`, `attn_gate`, and `value_residual` source paths are present again
  - `python -m py_compile` passed
- Rerun this branch in the `pr824-fixups` wave and verify the startup log shows both the PR824 flags and the intended QK-gain setting.
