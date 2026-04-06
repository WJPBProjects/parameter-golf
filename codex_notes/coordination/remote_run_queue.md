# Remote Run Queue

Use this file with:

- `codex_notes/coordination_live/experiment_board.md`
- `codex_notes/coordination_live/remote_pod_inventory.md`
- `codex_notes/coordination_live/remote_experiment_playbook.md`
- `codex_notes/coordination_live/submission_batch_queue.tsv`

## Current operating decision

- The `1xH100` lane is not trusted for candidate ranking.
- The `8xH100` lane is trusted.
- Remote candidate ranking should therefore happen only on the `8xH100` submission lane.
- Current budget policy is one warm `8xH100` pod at a time.

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

1. fill queue A first:
   - `submission_batch_queue_a.tsv`
2. run queue A on one warm `8xH100` pod
3. keep that pod warm only for queue A
4. stop it immediately when queue A finishes
5. only then consider queue B and queue C, if budget remains and the earlier results justify more spend

## Candidates worth considering first

- `late-value-embed-qk5`
  - original value-path candidate; clean syntax and tiny CPU PyTorch forward preflight on `2026-04-06`
- `embedding-skip-parallel-late`
  - original embedding-reuse candidate; clean syntax and tiny CPU PyTorch forward preflight on `2026-04-06`
- `parallelres-qkgain5`
  - lower-novelty fallback with prior local signal
- `compile-safe-late-qat`
  - CUDA-only fallback; do not run before the cleaner original queue A branches

## Candidates not worth spending `8xH100` time on right now

- stale local-only value-path family branches
- straight public-PR controls unless used as diagnostics
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

Operationally:

- queue A is the default next live queue
- queue B and queue C are overflow queues, not default parallel launches
