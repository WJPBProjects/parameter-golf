# Remote Workflow Handoff

Date: `2026-04-06`

## What changed

- Added a standardized stage-3 remote validation runner:
  - `scripts/run_remote_experiment.sh`
- Added a standardized stage-4 true submission runner for `8xH100`:
  - `scripts/run_remote_submission_8xh100.sh`
- Added a helper to create the single reserved `8xH100` submission pod:
  - `scripts/create_remote_submission_pod.sh`
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

## Current operating model

1. Local screen
2. Local confirm
3. Remote validation on cheaper CUDA, usually `1xH100`
4. True submission-style run on `8xH100 SXM`

## Important policy

- Up to `3` parallel stage-3 validation runs are allowed on the `1xH100` fleet.
- The stage-4 `8xH100` submission lane is single-threaded:
  - one pod
  - one active run
  - keep it stopped unless actively needed
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

- Validation Pod A:
  - `untjvs1cx2gq4u`
- Validation Pod B:
  - `2ollt57dzbud46`
- Validation Pod C:
  - `94x77u15s3v7s2`
- Submission Pod:
  - `slc7ozmtif62ih`

## Current pod state intent

- Validation pods can be started as needed for parallel stage-3 runs.
- Submission pod should remain stopped until a branch has earned a true stage-4 shot.

## Recommended next action

- Use the validation fleet to keep screening novel branches.
- Reserve the `8xH100` lane for only the strongest remotely validated novel candidate.
