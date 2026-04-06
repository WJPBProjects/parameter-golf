# Active Run Status

Last updated: 2026-04-06 16:50 UTC

## Current execution

- Active wave: `PAUSED`
- Profile: `remote merged-record calibration complete`
- Current pod:
  - `none`
- Current experiment:
  - `none`

## Completed calibration

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

## Current result directory

- `/Users/wulfie/code/parameter-golf/remote_results/20260406_171426_merged_record_signalrush`

## Next actions after this run

1. audit why the exact merged record degrades so badly on this stage-3 setup
2. compare hardware/runtime assumptions against the record README
3. do not spend more remote validation time on subtle candidate ranking until calibration is explained
4. if remote work continues, favor explicit reproduction/debugging runs over candidate fishing

## Billing rule

- no other pods should be left running unless they are actively serving the current batch
- the calibration pod has already been stopped
