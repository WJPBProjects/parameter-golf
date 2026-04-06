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

## Novelty rule

Use public PR-inspired work as controls and reference points, not as final submission targets by default.

- A straight reimplementation of an existing PR can still be useful locally or as a remote positive control.
- The true `8xH100` submission stage should be reserved for ideas that are plausibly novel enough to submit.
- Novel enough usually means at least one of:
  - a new composition across previously separate ideas
  - a new extension of an existing idea
  - a materially different variant with evidence that the interaction is additive

Do not spend the single-lane `8xH100` submission budget on a branch whose only claim is “we reproduced someone else's PR” unless the user explicitly asks for that.

## Promote to remote when

Promote if at least one of these is true:

- local full run shows clearly better `val_bpb` than the saved local baseline
- local full run is roughly tied on `val_bpb` but clearly better on artifact size
- local full run is roughly tied on quality and clearly faster
- the idea is CUDA- or systems-specific and local MLX is not a fair test
- the idea is scientifically unusual but shows credible signs of life worth validating

For stage 4 true submission promotion, also require:

- a credible novelty story
- not merely a direct copy of an existing public PR
- enough stage 3 remote evidence to justify using the single submission lane

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
