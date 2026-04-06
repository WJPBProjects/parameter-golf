# Experiment Note

## Experiment

- Name: Late Value Embed + QK5
- Status: PASS
- Owner: `main-agent`
- Branch: `codex/late-value-embed-qk5`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/late-value-embed-qk5`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/late-value-embed-qk5/train_gpt.py`
  - `experiments/late-value-embed-qk5/train_gpt_mlx.py`

## Hypothesis

- A late-only shared value-embedding path, combined with stronger QK gain, may improve the value stream cheaply enough to survive artifact constraints.

## Scope

- Files changed:
  - `experiments/late-value-embed-qk5/train_gpt.py`
  - `experiments/late-value-embed-qk5/train_gpt_mlx.py`
- Local screen command(s):
  - MLX is not a faithful signal for the value-embedding delta in this branch.
  - CPU preflight used instead.
- Remote run command(s):
  - `VE_ENABLED=1 VE_DIM=128 VE_LAYERS=7,8 QK_GAIN_INIT=5.0 VAL_LOSS_EVERY=1500`

## Progress

- `py_compile` passed for both trainer copies on `2026-04-06`.
- Local CPU import + model-instantiation + forward-pass preflight passed on `2026-04-06`.
- Local MLX runner smoke passed on `2026-04-06`:
  - `/Users/wulfie/code/parameter-golf-worktrees/late-value-embed-qk5/logs/preflight_late_value_embed_qk5_20260406_215133.txt`
- This is one of the first original candidates selected for the next `8xH100` queue.

## Local Screening

- Status: PASS
- Notes:
  - Preflight only; no MLX metric is trusted here because the MLX copy does not reflect the remote mechanism well enough for ranking.
  - Latest smoke proved the branch-local MLX path, data, tokenizer, logging, and artifact paths still work.

## Promotion Decision

- Promote to remote: YES
- Reason:
  - original mechanism
  - clean local preflight
  - low apparent setup risk
- Remote priority:
  - queue A

## Remote Training

- Status: TODO
- Date:
  - `2026-04-06`
- Machine / provider:
  - `RunPod 8xH100`
- Run identifier:
  - `submission8x_late-value-embed-qk5_20260406_220224`
- Log path:
  - remote: `/workspace/parameter-golf/logs/submission8x_late-value-embed-qk5_20260406_215841.txt`
- Notes:
  - aborted before a valid metric
  - transient SSH monitor failure left duplicate remote `torchrun` jobs alive during retries
  - Pod C was stopped and the local batch runner was fixed before rerunning

## Next step

- Run on the first `8xH100` batch ahead of derivative branches.
