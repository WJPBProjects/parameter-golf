# Active Run Status

Last updated: 2026-04-06 22:05 UTC

## Current execution

- Active wave: `PAUSED_REMOTE_BALANCE`
- Profile: `8xH100 remote ranking lane with dynamic pod-id SSH`
- Current pod:
  - `none`
- Current experiment:
  - `none`

## Current blocker

- RunPod balance is below the minimum resume threshold for an `8xH100` on-demand pod.
- Current observed error from `runpodctl pod start`:
  - `Insufficient balance to resume this on-demand pod. You need at least $3.59 (current: $3.01, deficit: $0.58).`
- Consequence:
  - no new `8xH100` pod can be started until credits are added
  - repo and queues are being prepared offline in the meantime

## Latest remote attempts

- Pod `p0q5f3wenzygvr` (`parameter-golf-8xh100-calibration-2`) exited twice under RunPod control during setup and has since been deleted from the fleet:
  - `Exited by RunPod: 2026-04-06 19:44:38 UTC`
  - `Exited by RunPod: 2026-04-06 19:49:38 UTC`
- `compile-safe-late-qat` failure sequence:
  - first retry exposed missing remote train-script preflight
  - second retry exposed missing tokenizer cache on the pod volume
- Infra fixes now in local `main` working tree:
  - dynamic pod-id SSH resolution in `scripts/run_remote_submission_batch.sh`
  - retry-through-port-churn in `ssh_cmd`
  - remote process death detection to avoid hour-long dead waits
  - tokenizer/vocab presence added to remote bootstrap checks
  - remote train-script preflight fallback to branch-root `train_gpt.py` when needed

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
- `/Users/wulfie/code/parameter-golf/remote_results/submission_batches/20260406_201647_submission_batch_queue_a`

## Next actions after this run

1. add enough RunPod credit to resume at least one `8xH100` pod
2. resume the remote lane with exactly one warm `8xH100` pod:
   - prefer Pod A
   - use Pod C only as fallback
3. run queue A first:
   - `compile-safe-late-qat`
   - `late-value-embed-qk5`
4. only if queue A completes cleanly and budget remains, run queue B:
   - `parallelres-qkgain5`
5. only if budget still remains, run queue C:
   - `late-value-embed-legal-ttt`
   - `embedding-skip-parallel-late`
6. keep the pod warm only while its current queue is active, and stop immediately after
7. do not spend paid `8xH100` time on repeated setup debugging; stop and fix locally first

## Billing rule

- no other pods should be left running unless they are actively serving the current batch
- all `1xH100` validation pods have been deleted
- Pod B has been deleted from the `8xH100` fleet after instability
- all remaining `8xH100` fleet pods are currently stopped
