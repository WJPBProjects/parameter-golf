# Experiment Note

## Experiment

- Name: Embedding Skip Parallel Late
- Status: PASS
- Owner: `main-agent`
- Branch: `codex/embedding-skip-parallel-late`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/embedding-skip-parallel-late`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/embedding-skip-parallel-late/train_gpt.py`
  - `experiments/embedding-skip-parallel-late/train_gpt_mlx.py`

## Hypothesis

- A small shared skip-embedding path injected only into late layers may recycle token-level structure cheaply and complement stronger QK geometry.

## Scope

- Files changed:
  - `experiments/embedding-skip-parallel-late/train_gpt.py`
  - `experiments/embedding-skip-parallel-late/train_gpt_mlx.py`
- Local screen command(s):
  - CPU preflight used instead of MLX ranking.
- Remote run command(s):
  - `SKIP_EMB_ENABLED=1 SKIP_EMB_DIM=128 SKIP_EMB_LAYERS=6,7,8 QK_GAIN_INIT=5.0 VAL_LOSS_EVERY=1500`

## Progress

- `py_compile` passed for both trainer copies on `2026-04-06`.
- Local CPU import + model-instantiation + forward-pass preflight passed on `2026-04-06`.
- Local MLX runner smoke passed on `2026-04-06`:
  - `/Users/wulfie/code/parameter-golf-worktrees/embedding-skip-parallel-late/logs/preflight_embedding_skip_parallel_late_20260406_215152.txt`
- Selected as the second original candidate for the next `8xH100` queue.

## Local Screening

- Status: PASS
- Notes:
  - Preflight only; no MLX score is being treated as meaningful for this branch.
  - Latest smoke proved the branch-local MLX path, data, tokenizer, logging, and artifact paths still work.

## Promotion Decision

- Promote to remote: YES
- Reason:
  - original mechanism
  - clean local preflight
  - low apparent setup risk
- Remote priority:
  - queue A

## Next step

- Run after `late-value-embed-qk5` on the first `8xH100` batch.
