# Active Run Status

Last updated: 2026-04-06 20:45 UTC

## Current execution

- Active wave: `PAUSED`
- Profile: `8xH100 fleet prepared for batch ranking`
- Current pod:
  - `none`
- Current experiment:
  - `none`

## Completed calibrations

- Same-pod baseline:
  - `remote_merged_record_baseline_20260406_171426`
  - post-quant `val_bpb: 1.32581447`
  - `step_avg: 418.21ms`
- Exact merged record control:
  - `remote_merged_record_signalrush_20260406_171426`
  - final quantized `val_bpb: 2.32295979`
  - `step_avg: 665.24ms`
  - wrapper hung after logging; outputs were pulled back manually and the pod was stopped cleanly
- Interpretation:
  - this stage-3 `1xH100` harness does not reproduce that merged record directionally
  - remote calibration is still not trustworthy as a leaderboard proxy

Submission-lane calibration:

- Run id:
  - `submission8x_merged_record_signalrush_20260406_180723`
- Pod:
  - `bg36rohzqz8svz`
- exact merged record on true `8xH100`:
  - in-run `val_bpb: 1.1468`
  - post-EMA diagnostic `val_bpb: 1.1462`
  - final quantized exact `val_bpb: 1.15421071`
  - `step_avg: 105.17ms`
- Interpretation:
  - the exact record behaves sensibly on the real submission lane
  - the broken piece is the `1xH100` proxy, not the overall remote setup

## Current result directories

- `/Users/wulfie/code/parameter-golf/remote_results/20260406_171426_merged_record_signalrush`
- `/Users/wulfie/code/parameter-golf/remote_results/20260406_180723_submission_record_signalrush`

## Next actions after this run

1. fill the per-pod batch queue files:
   - `codex_notes/coordination/submission_batch_queue_a.tsv`
   - `codex_notes/coordination/submission_batch_queue_b.tsv`
   - `codex_notes/coordination/submission_batch_queue_c.tsv`
2. launch up to `3` parallel `8xH100` batch runners
3. keep each pod warm only for its own queue
4. stop and release each pod immediately after its queue finishes

## Billing rule

- no other pods should be left running unless they are actively serving the current batch
- all `1xH100` validation pods have been deleted
- all `8xH100` fleet pods are currently stopped
