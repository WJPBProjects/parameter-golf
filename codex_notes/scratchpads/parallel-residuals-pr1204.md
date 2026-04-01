# Experiment Note

## Experiment

- Name: Parallel Residuals (PR1204-inspired)
- Status: IN_PROGRESS:main-agent
- Owner: `main-agent`
- Branch: `codex/parallel-residuals-pr1204`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/parallel-residuals-pr1204`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/parallel-residuals-pr1204/train_gpt.py`
  - `experiments/parallel-residuals-pr1204/train_gpt_mlx.py`

## Hypothesis

- Splitting late layers into attention and MLP residual lanes with learned cross-routing may improve the local harness in the same direction as PR #1204.

## Scope

- Files changed:
  - `experiments/parallel-residuals-pr1204/train_gpt_mlx.py`
- Local screen command(s):
  - `TRAIN_MLX_SCRIPT=experiments/parallel-residuals-pr1204/train_gpt_mlx.py bash scripts/run_local_confirm_mlx.sh`
- Remote run command(s):
  - `TBD`

## Progress

- Fresh local partial port on top of the current baseline.
- Scope is intentionally smaller than the full PR:
  - includes parallel residual lanes
  - does not yet include mini depth recurrence
- One mistaken concurrent MLX smoke was started and then killed; no result from that run should be trusted.
- Current state:
  - syntax check passes
  - sequential local run still pending

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

- Run this after the historical rerun wave completes so the MLX comparisons stay sequential and clean.
