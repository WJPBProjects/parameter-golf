# Remote Run Queue

Use this file with:

- `codex_notes/coordination_live/experiment_board.md`
- `codex_notes/coordination_live/remote_pod_inventory.md`
- `codex_notes/coordination_live/remote_experiment_playbook.md`

The queue below reflects the stronger April 2 local confirm wave, not the older March-only shortlist.

## Run order on a fresh pod

1. baseline sanity run
2. PR824 mimic positive control
3. highest-priority promoted candidate
4. second promoted candidate
5. CUDA-only exploratory branch if there is still time

## Canonical baseline and control

### 1. Baseline sanity run

- Status: `TODO`
- Why:
  - every promoted experiment should be judged against a same-pod baseline
- Command:
  - `bash scripts/run_remote_experiment.sh baseline train_gpt.py`

### 2. PR824 mimic positive control

- Status: `TODO`
- Branch:
  - `codex/pr824-mimic-gatedattn-valueresid`
- Worktree:
  - `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid`
- Why:
  - this is the current trusted exploit-family positive control
  - fresh local confirm: `1.66770976` on `pr824_stacks_20260402`
- Command:
  - `bash scripts/run_remote_experiment.sh pr824-mimic experiments/pr824-mimic-gatedattn-valueresid/train_gpt.py`

## Highest-priority promoted candidates

### 3. PR824 + KGIIR-lite

- Status: `TODO`
- Branch:
  - `codex/pr824-kgiir-lite`
- Worktree:
  - `/Users/wulfie/code/parameter-golf-worktrees/pr824-kgiir-lite`
- Why:
  - current best local result
  - fresh local confirm: `1.65947391`
  - beats local baseline, PR824 mimic, and `pr824-qkgain5`
- Command:
  - `bash scripts/run_remote_experiment.sh pr824-kgiir-lite experiments/pr824-kgiir-lite/train_gpt.py`

### 4. PR824 + QK_GAIN=5.0

- Status: `TODO`
- Branch:
  - `codex/pr824-qkgain5`
- Worktree:
  - `/Users/wulfie/code/parameter-golf-worktrees/pr824-qkgain5`
- Why:
  - strong local exploit win
  - fresh local confirm: `1.66190993`
  - currently the best simpler stack behind `pr824-kgiir-lite`
- Command:
  - `bash scripts/run_remote_experiment.sh pr824-qkgain5 experiments/pr824-qkgain5/train_gpt.py`

## Remote-only / CUDA-specific follow-up

### 5. Compile-safe Late-QAT

- Status: `TODO`
- Branch:
  - `codex/compile-safe-late-qat`
- Worktree:
  - `/Users/wulfie/code/parameter-golf-worktrees/compile-safe-late-qat`
- Why:
  - local MLX is not a fair test for this CUDA / compile path
- Command:
  - `QAT_ENABLED=1 LATE_QAT_THRESHOLD=0.15 bash scripts/run_remote_experiment.sh compile-safe-late-qat experiments/compile-safe-late-qat/train_gpt.py`

## Lower-priority remote coverage only if we want more data

- `PR824 + AttnRes-lite`
  - real local win and faster than PR824 mimic, but behind the stronger promoted pair
- `XSA all layers`
  - still only a modest local positive

## Do not spend remote time on these right now

- `Selective post-GPTQ pruning`
- `GPTQ self calibration`
- `RoPE + LN-scale grid`
- `LeakyReLU slope sweep`
- `Hyperconnection-lite`
- `MoHD last-MLP lite`

These are either local regressions, too ambiguous, or clearly weaker than the current promoted queue.
