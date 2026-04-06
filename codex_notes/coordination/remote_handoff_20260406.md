# Remote Workflow Handoff

Date: `2026-04-06`

## What changed

- Added a standardized stage-3 remote validation runner:
  - `scripts/run_remote_experiment.sh`
- Added a standardized stage-4 true submission runner for `8xH100`:
  - `scripts/run_remote_submission_8xh100.sh`
- Added a helper to create `8xH100` submission-fleet pods:
  - `scripts/create_remote_submission_pod.sh`
- Added claim/release helpers for the new `3`-pod `8xH100` ranking fleet:
  - `scripts/claim_remote_submission_pod.sh`
  - `scripts/release_remote_submission_pod.sh`
- Added a local batch runner for the `8xH100` fleet:
  - `scripts/run_remote_submission_batch.sh`
- Made local stage wallclock caps explicit:
  - `scripts/run_local_screen_mlx.sh` -> `600s`
  - `scripts/run_local_confirm_mlx.sh` -> `5400s`
  - `scripts/run_local_overnight_mlx.sh` -> `21600s`
- Added remote coordination docs:
  - `codex_notes/coordination_live/remote_experiment_playbook.md`
  - `codex_notes/coordination_live/remote_pod_inventory.md`
- Updated policy docs:
  - `AGENTS.md`
  - `codex_notes/coordination_live/promotion_rubric.md`
  - `codex_notes/coordination_live/remote_run_queue.md`
- Fixed the remote wrappers so they actually tee `torchrun` output into the claimed log path:
  - `scripts/run_remote_experiment.sh`
  - `scripts/run_remote_submission_8xh100.sh`
- Added a local pullback helper for finished remote runs:
  - `scripts/pull_remote_run_artifacts.sh`
- Added a local stage-3 queue runner that executes baseline, a merged-record control, and one candidate over SSH:
  - `scripts/run_remote_validation_sequence.sh`
- Added local validation-pod claim/release helpers:
  - `scripts/claim_remote_validation_pod.sh`
  - `scripts/release_remote_validation_pod.sh`
- Made the stage-3 queue runner restart-safe:
  - `START_STAGE=control|candidate`
  - `BASELINE_RUN_ID=...`
  - `CONTROL_RUN_ID=...`
  - `SKIP_REMOTE_SETUP=1`
- Fixed multi-stage remote cleanliness by ignoring:
  - `artifacts/`

## Minimum expected repo state

Before using the remote wrappers, make sure the checkout includes the log-capture fix.

- Required behavior:
  - `scripts/run_remote_experiment.sh` writes `logs/<RUN_ID>.txt`
  - `scripts/run_remote_submission_8xh100.sh` writes `logs/<RUN_ID>.txt`
- Practical check:
  - both scripts should contain `| tee "$LOG_PATH"` in the `torchrun` line
- Reason:
  - without that, the wrapper cannot satisfy the repo's own remote-result validity rules
  - the summary file will claim a log path that was never written
- Also make sure:
  - `.gitignore` includes `artifacts/`
- Reason:
  - without that, a successful baseline run dirties the remote repo and the next control/candidate stage will fail its pre-run cleanliness check

## Current operating model

1. Local screen
2. Local confirm
3. Real remote ranking on the `3`-pod `8xH100` fleet
4. Submission or rerun confirmation on the same `8xH100` lane

## Important policy

- The `1xH100` validation fleet has been retired and deleted.
- The `8xH100` lane now has `3` pods and is the main remote ranking lane.
- Run one sequential candidate batch per claimed pod.
- Keep all three pods stopped unless they are actively serving a batch.
- Do not spend the `8xH100` submission lane on a straight reimplementation of an existing PR.
- Existing PR-inspired branches are allowed as controls, not default final submission targets.

## Where to look first

- Main remote workflow doc:
  - `codex_notes/coordination_live/remote_experiment_playbook.md`
- Pod ids and lifecycle commands:
  - `codex_notes/coordination_live/remote_pod_inventory.md`
- Which branches to run first:
  - `codex_notes/coordination_live/remote_run_queue.md`
- Novelty and promotion policy:
  - `codex_notes/coordination_live/promotion_rubric.md`
  - `AGENTS.md`

## Current pod inventory

- `8xH100` Pod A:
  - `bg36rohzqz8svz`
- `8xH100` Pod B:
  - `p0q5f3wenzygvr`
- `8xH100` Pod C:
  - `h91bgyz08fp9dk`

## Current pod state intent

- All three `8xH100` pods should remain stopped until claimed by a batch runner.
- Each claimed pod should stay warm only for its own sequential queue.
- Stop the pod immediately when its queue finishes.

## Recommended next action

- Fill the three per-pod queue files:
  - `submission_batch_queue_a.tsv`
  - `submission_batch_queue_b.tsv`
  - `submission_batch_queue_c.tsv`
- Launch up to `3` parallel `8xH100` batch runners with `auto` pod claiming.
