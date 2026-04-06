# Remote Experiment Playbook

This is the operator README for remote ranking runs.

Use it together with:

- `codex_notes/coordination_live/remote_pod_inventory.md`
- `codex_notes/coordination_live/remote_run_queue.md`
- `codex_notes/coordination_live/submission_batch_queue.tsv`
- `codex_notes/coordination_live/submission_batch_queue_a.tsv`
- `codex_notes/coordination_live/submission_batch_queue_b.tsv`
- `codex_notes/coordination_live/submission_batch_queue_c.tsv`
- `codex_notes/coordination_live/promotion_rubric.md`

## Current policy

- The old `1xH100` validation lane is no longer trusted for ranking.
- The main remote path is now the `8xH100` submission fleet.
- The fleet has `3` parallel lanes.
- Each lane should process a sequential batch of candidates on one warm pod.

## Why

We calibrated the exact merged leaderboard record in both regimes:

- `1xH100` stage-3 proxy:
  - misleading
- `8xH100` true lane:
  - directionally correct

So candidate ranking should happen on `8xH100`, not on the old `1xH100` proxy.

## Core scripts

- create a new `8xH100` pod:
  - `scripts/create_remote_submission_pod.sh`
- claim one of the three fleet pods:
  - `scripts/claim_remote_submission_pod.sh`
- release one of the three fleet pods:
  - `scripts/release_remote_submission_pod.sh`
- single remote submission runner on the pod:
  - `scripts/run_remote_submission_8xh100.sh`
- local artifact pullback:
  - `scripts/pull_remote_run_artifacts.sh`
- local batch driver:
  - `scripts/run_remote_submission_batch.sh`

## Queue format

The batch driver reads:

- `codex_notes/coordination_live/submission_batch_queue.tsv`

Format:

- `slug<TAB>branch<TAB>train_script<TAB>extra_env(optional)`

Example:

```text
compile-safe-late-qat	codex/compile-safe-late-qat	experiments/compile-safe-late-qat/train_gpt.py	QAT_ENABLED=1 LATE_QAT_THRESHOLD=0.15
xsa-all	codex/xsa-all	experiments/xsa-all/train_gpt.py	
```

Reference policy:

- the preferred reference is a shared curve at:
  - `codex_notes/coordination_live/submission_reference_curve.tsv`
- this should come from a trusted `8xH100` control or champion run with periodic validation enabled
- later candidates should be judged against that shared reference so the same standard applies across queues
- if no shared reference exists yet, the batch runner can fall back to capturing a queue-local reference from the first completed run
- that fallback is only a budget-defense convenience, not the ideal long-term ranking policy

Recommended convention:

- put a control or trusted baseline first in each per-pod queue until the shared reference curve exists
- the batch runner forces periodic validation by default with:
  - `VAL_LOSS_EVERY=1500`
  - unless the queue entry already overrides it

## Early-stop defense

- The batch runner now has a budget-defense mode enabled by default.
- After about `65%` of the configured wallclock budget, a candidate can be stopped early only if it is both:
  - clearly behind the active reference curve
  - and no longer improving meaningfully on its own recent validation checkpoints
- Default threshold:
  - candidate worse than reference by more than `0.0300 val_bpb`
  - and recent self-improvement below `0.0050 val_bpb`
- This only activates after a reference curve exists, so the first run in each queue should be a control.
- It also requires at least `2` validation checkpoints from the candidate itself.
- Early-stopped runs still get:
  - pulled logs
  - summary file
  - any artifacts that exist
  - recorded status

## Recommended launch pattern

One local agent per pod:

```bash
bash scripts/run_remote_submission_batch.sh auto codex_notes/coordination/submission_batch_queue_a.tsv
bash scripts/run_remote_submission_batch.sh auto codex_notes/coordination/submission_batch_queue_b.tsv
bash scripts/run_remote_submission_batch.sh auto codex_notes/coordination/submission_batch_queue_c.tsv
```

The batch runner will:

1. claim a stopped `8xH100` pod
2. start it
3. bootstrap the repo from the local `origin` remote
4. bootstrap data if needed
5. push/fetch the requested branch
6. run the candidate
7. monitor the remote log until the final quantized metric appears
8. finalize artifacts even if the remote wrapper hangs
9. pull logs and artifacts back locally
10. stop and release the pod by default

## What counts as a valid ranked result

A run is valid if:

- the log exists locally
- the final quantized exact metric exists locally
- the artifact exists locally
- the branch/script/run id are recorded
- the pod is stopped after the batch

## Operational rules

- Do not leave idle pods running.
- Do not multiplex multiple active candidates on the same pod at once.
- Do batch multiple candidates sequentially on the same warm pod.
- Push candidate branches before sending them to the remote fleet.
- If a run looks suspicious, prefer a second `8xH100` confirmation over a long `1xH100` proxy.
