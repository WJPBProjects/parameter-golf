# Remote Run Queue

Use this file with:

- `codex_notes/coordination_live/experiment_board.md`
- `codex_notes/coordination_live/remote_pod_inventory.md`
- `codex_notes/coordination_live/remote_experiment_playbook.md`

The queue below reflects the current merged-record calibration policy.

## Run order on a fresh pod

1. baseline sanity run
2. exact merged-record control
3. highest-priority promoted candidate
4. second promoted candidate
5. CUDA-only exploratory branch if there is still time

## Canonical baseline and control

### 1. Baseline sanity run

- Status: `DONE`
- Why:
  - every promoted experiment should be judged against a same-pod baseline
- Command:
  - `bash scripts/run_remote_experiment.sh baseline train_gpt.py`
- Latest result:
  - previous shakedown baseline from `2026-04-06`
  - post-quant `val_bpb: 1.33471717`
  - log:
    - see the `2026-04-06` remote shakedown result directory under `remote_results/`

### 2. Exact merged-record control

- Status: `IN_PROGRESS`
- Branch:
  - `main`
- Why:
  - remote calibration should use an exact merged leaderboard record, not a partial public-PR mimic
  - current control target:
    - `records/track_10min_16mb/2026-03-22_11L_EMA_GPTQ-lite_warmdown3500_QAT015_1.1233/train_gpt.py`
  - claimed merged-record score:
    - `1.1228`
- Command:
  - `bash scripts/run_remote_experiment.sh merged-record-signalrush records/track_10min_16mb/2026-03-22_11L_EMA_GPTQ-lite_warmdown3500_QAT015_1.1233/train_gpt.py`

## Highest-priority promoted candidates

### 3. Compile-safe Late-QAT

- Status: `TODO`
- Branch:
  - `codex/compile-safe-late-qat`
- Worktree:
  - `/Users/wulfie/code/parameter-golf-worktrees/compile-safe-late-qat`
- Why:
  - local MLX is not a fair test for this CUDA / compile path
  - this is a cleaner remote-only candidate than the stale local-only value-path family
- Command:
  - `QAT_ENABLED=1 LATE_QAT_THRESHOLD=0.15 bash scripts/run_remote_experiment.sh compile-safe-late-qat experiments/compile-safe-late-qat/train_gpt.py`

### 4. XSA all layers

- Status: `TODO`
- Branch:
  - `codex/xsa-all`
- Worktree:
  - `/Users/wulfie/code/parameter-golf-worktrees/xsa-all`
- Why:
  - modest but repeatable local improvement
  - simple, low-risk architecture delta worth checking on CUDA
- Command:
  - `bash scripts/run_remote_experiment.sh xsa-all experiments/xsa-all/train_gpt.py`

## Remote-only / CUDA-specific follow-up

### 5. Latest merged-record calibration reruns

- Status: `TODO`
- Why:
  - if the first merged-record calibration lands in the right ballpark, rerun it on one more fresh pod to confirm the remote harness is stable
- Command:
  - `bash scripts/run_remote_experiment.sh merged-record-signalrush records/track_10min_16mb/2026-03-22_11L_EMA_GPTQ-lite_warmdown3500_QAT015_1.1233/train_gpt.py`

## Lower-priority remote coverage only if we want more data

- `SplineConv hybrid`
  - neutral locally, but still an architectural idea that could behave differently on CUDA
- `Parallel Residuals (PR1204-inspired)`
  - real local win, but weaker than the current promoted queue

## Do not spend remote time on these right now

- stale local-only value-path family branches
- `Selective post-GPTQ pruning`
- `GPTQ self calibration`
- `RoPE + LN-scale grid`
- `LeakyReLU slope sweep`
- `Hyperconnection-lite`
- `MoHD last-MLP lite`

These are either local regressions, too ambiguous, or clearly weaker than the current promoted queue.
