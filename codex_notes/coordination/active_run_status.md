# Active Run Status

Last updated: 2026-04-06 17:27 UTC

## Current execution

- Active wave: `PAUSED`
- Profile: `remote merged-record calibration complete`
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

## Current result directory

- `/Users/wulfie/code/parameter-golf/remote_results/20260406_171426_merged_record_signalrush`

## Next actions after this run

1. stop treating the current `1xH100` lane as a leaderboard-ranking proxy
2. use `8xH100` for decisive ranking when it matters
3. if a cheaper proxy is still desired, recalibrate a new one explicitly against this successful `8xH100` result
4. only then resume candidate fishing on cheaper remote hardware

## Billing rule

- no other pods should be left running unless they are actively serving the current batch
- all calibration pods have been stopped
