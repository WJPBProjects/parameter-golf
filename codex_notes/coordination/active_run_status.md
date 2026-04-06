# Active Run Status

Last updated: 2026-04-06 21:08 UTC

## Current execution

- Active wave: `PAUSED_REMOTE_RUNNER_FIX`
- Profile: `8xH100 remote ranking lane, one-pod queue A`
- Current pod:
  - `none`
- Current experiment:
  - `none`

## Current blocker

- None after runner fix; all pods are stopped.

## Latest aborted remote run

- Run id:
  - `submission8x_late-value-embed-qk5_20260406_220224`
- Pod:
  - `h91bgyz08fp9dk`
- Branch:
  - `codex/late-value-embed-qk5`
- Train script:
  - `experiments/late-value-embed-qk5/train_gpt.py`
- Extra env:
  - `VE_ENABLED=1 VE_DIM=128 VE_LAYERS=7,8 QK_GAIN_INIT=5.0 VAL_LOSS_EVERY=1500`
- Launch mode:
  - manual retry on the already-running `8xH100` pod
- Current status:
  - invalid / aborted before any trusted metric
  - transient SSH monitor failure left duplicate `torchrun` jobs alive during retries
  - killed the remote training processes and stopped Pod C
  - fixed `scripts/run_remote_submission_batch.sh` so monitoring SSH failures do not exit the runner and remote prelaunch cleanup kills stale trainer processes before a new launch

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

1. rerun queue A after the runner fix:
   - `late-value-embed-qk5`
   - `embedding-skip-parallel-late`
2. evaluate whether either queue A candidate earns a second run or submission package
3. only after that consider overflow queue B:
   - `parallelres-qkgain5`
   - `compile-safe-late-qat`
4. only if budget still remains, run queue C:
   - `late-value-embed-legal-ttt`
5. keep the pod warm only while its current run or queue is active, and stop immediately after
6. do not spend paid `8xH100` time on repeated setup debugging; stop and fix locally first

## Latest local preflight before resumed spend

- `late-value-embed-qk5`:
  - `py_compile` passed for CUDA and MLX trainer copies
  - PyTorch trainer import / tiny CPU `GPT` instantiate / forward pass passed
- `embedding-skip-parallel-late`:
  - `py_compile` passed for CUDA and MLX trainer copies
  - PyTorch trainer import / tiny CPU `GPT` instantiate / forward pass passed
- `compile-safe-late-qat`, `parallelres-qkgain5`, and `xsa-all`:
  - `py_compile` passed for CUDA and MLX trainer copies
  - PyTorch trainer import / tiny CPU `GPT` instantiate / forward pass passed
- Caveat:
  - some branches do not have MLX implementations for their remote-only features, so a local MLX run would not validate the actual remote hypothesis

## Billing rule

- no other pods should be left running unless they are actively serving the current run or batch
- all `1xH100` validation pods have been deleted
- Pod B has been deleted from the `8xH100` fleet after instability
- all remaining `8xH100` fleet pods are currently stopped
