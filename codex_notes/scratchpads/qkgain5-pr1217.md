# Experiment Note

## Experiment

- Name: QK_GAIN=5.0 (PR1217-inspired)
- Status: TODO
- Owner: `main-agent`
- Branch: `codex/qkgain5-pr1217`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/qkgain5-pr1217`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/qkgain5-pr1217/train_gpt.py`
  - `experiments/qkgain5-pr1217/train_gpt_mlx.py`

## Hypothesis

- A higher `QK_GAIN_INIT` may improve attention sharpness enough to show a directional local win, matching the contribution claimed in PR #1217.

## Scope

- Files expected to change:
  - none required for first pass; use env override
- Local screen command(s):
  - `QK_GAIN_INIT=5.0 TRAIN_MLX_SCRIPT=experiments/qkgain5-pr1217/train_gpt_mlx.py bash scripts/run_local_confirm_mlx.sh`
- Remote run command(s):
  - `TBD`

## Progress

- Latest-PR signal-check experiment.
- Cheap first pass because it does not need a code patch.

## Local Screening

- Status: TODO

## Promotion Decision

- Promote to remote:
- Reason:
- Remote priority:

## Remote Training

- Status: TODO

## Conclusion

- 

## Next step

- Run it after the historical rerun wave finishes and compare directly against `baseline_long_new_laptop`.
