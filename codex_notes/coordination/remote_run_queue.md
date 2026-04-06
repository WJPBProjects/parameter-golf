# Remote Run Queue

Use this file with:

- `codex_notes/coordination_live/experiment_board.md`
- `codex_notes/coordination_live/remote_pod_inventory.md`
- `codex_notes/coordination_live/remote_experiment_playbook.md`
- `codex_notes/coordination_live/submission_batch_queue.tsv`

## Current operating decision

- The `1xH100` lane is not trusted for candidate ranking.
- The `8xH100` lane is trusted.
- Remote candidate ranking should therefore happen on the `3`-pod `8xH100` fleet.

## Calibration summary

- `1xH100` exact merged record:
  - misleading
  - see:
    - `codex_notes/coordination/merged_record_calibration_20260406.md`
- `8xH100` exact merged record:
  - directionally correct
  - see:
    - `codex_notes/coordination/submission_record_calibration_20260406.md`

## Current queue policy

When preparing a real batch:

1. fill the three per-pod queue files:
   - `submission_batch_queue_a.tsv`
   - `submission_batch_queue_b.tsv`
   - `submission_batch_queue_c.tsv`
2. group candidates into three pod-sized batches
3. run one batch per pod
4. keep each pod warm only for its own batch
5. stop all pods immediately when their batches finish

## Candidates worth considering first

- `compile-safe-late-qat`
  - CUDA-only path
- `xsa-all`
  - modest local positive and simple implementation

## Candidates not worth spending `8xH100` time on right now

- stale local-only value-path family branches
- `GPTQ self calibration`
- `Selective post-GPTQ pruning`
- `RoPE + LN-scale grid`
- `LeakyReLU slope sweep`
- `Hyperconnection-lite`
- `MoHD last-MLP lite`

## Queue file

The executable batch files are:

- `codex_notes/coordination/submission_batch_queue_a.tsv`
- `codex_notes/coordination/submission_batch_queue_b.tsv`
- `codex_notes/coordination/submission_batch_queue_c.tsv`
