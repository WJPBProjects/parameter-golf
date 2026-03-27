# Promotion Rubric

Use this file when deciding whether a locally screened idea should be promoted to remote training.

## Read before deciding

- `codex_notes/coordination/baseline_benchmarks.md`
- `codex_notes/coordination/experiment_board.md`
- the experiment's own scratchpad

## Default rule

Do not promote everything.

Local screening is for:

- bug detection
- obvious regressions
- early quality signal
- throughput signal
- artifact-size signal

Remote runs are for:

- confirming the best local ideas
- CUDA-specific behavior
- true competitive comparisons

## Promote to remote when

Promote if at least one of these is true:

- local full run shows clearly better `val_bpb` than the saved local baseline
- local full run is roughly tied on `val_bpb` but clearly better on artifact size
- local full run is roughly tied on quality and clearly faster
- the idea is CUDA- or systems-specific and local MLX is not a fair test
- the idea is scientifically unusual but shows credible signs of life worth validating

## Hold or reject when

Do not promote when any of these are true unless the user explicitly wants it:

- local screen is clearly worse on quality
- local screen is clearly slower with no compensating gain
- the change is unstable or broken
- the idea adds complexity but local signal is weak or noisy
- the experiment has not been isolated enough to explain the result

## Handling ambiguous cases

Use these statuses on the board:

- `READY`: strong case for remote promotion
- `HOLD`: interesting but not strong enough yet
- `FAIL`: local evidence says the idea is not worth promoting
- `BLOCKED`: cannot make a fair local call yet

If local MLX is not a fair test:

1. write down why
2. mark local status `BLOCKED` or `PASS` with a note
3. mark promotion `READY` only if there is a concrete reason the remote path is still justified

## What to record in the scratchpad

- exact local command
- exact remote command to run next
- baseline used for comparison
- why the idea should or should not be promoted
- the smallest next step if it stays on hold
