# Remote Run Queue

This file captures what is still genuinely left to do after the stronger local rerun wave.

Local rerun summary:

- `codex_notes/coordination/local_rerun_wave_20260327.md`

## Ready for remote now

1. `PR824 mimic: XSA6 + GatedAttn + ValueResid`

- Worktree:
  - `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid`
- Why:
  - clear best local result in the stronger rerun wave
  - post-quant `val_bpb` improved from `2.15725007` to `2.10420259`
- Local log:
  - `logs/pr824_mimic_long_seed1337.txt`
- Suggested first remote command:
  - `RUN_ID=pr824_mimic_remote ./.venv/bin/python experiments/pr824-mimic-gatedattn-valueresid/train_gpt.py`

## Remote only / not locally adjudicated

2. `Compile-safe Late-QAT`

- Worktree:
  - `/Users/wulfie/code/parameter-golf-worktrees/compile-safe-late-qat`
- Why:
  - this is a CUDA / `torch.compile` hypothesis, so the Mac cannot really judge it
- Suggested first remote command:
  - `QAT_ENABLED=1 LATE_QAT_THRESHOLD=0.15 RUN_ID=compile-safe-late-qat ./.venv/bin/python experiments/compile-safe-late-qat/train_gpt.py`

## Optional remote candidate only if we want extra coverage

3. `XSA all layers`

- Worktree:
  - `/Users/wulfie/code/parameter-golf-worktrees/xsa-all`
- Why:
  - still slightly positive locally, but the margin is tiny
  - worth a remote slot only if we want to sanity-check a low-confidence positive
- Local log:
  - `logs/xsa_all_long_seed1337_v2.txt`
- Suggested first remote command:
  - `XSA_LAST_N=9 RUN_ID=xsa_all_remote ./.venv/bin/python experiments/xsa-all/train_gpt.py`

## Do not promote right now

- `LeakyReLU slope sweep`
- `Selective post-GPTQ pruning` at `POST_GPTQ_PRUNE_FRACTION=0.02`
- `GPTQ self calibration`
- `RoPE + LN-scale` first screened point
- `SplineConv hybrid`

These either regressed or were too close to neutral to justify immediate remote spend.
