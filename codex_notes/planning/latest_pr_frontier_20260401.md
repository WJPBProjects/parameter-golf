# Latest Public PR Frontier (2026-04-01)

This note captures the public GitHub frontier that matters for local-only iteration right now.

## Current strong public references

### `PR #1229`

- Title:
  - `Record: Scored-Position SLOT + Per-Sample Delta + GPTQ (val_bpb: 0.9300)`
- Key ideas:
  - scored-position SLOT
  - per-sample delta-style adaptation
  - GPTQ stack
- Local portability:
  - weak for exact score due heavy eval-time machinery
  - moderate as a signal that `SLOT`-style scored-position ideas are now part of the frontier

### `PR #1218`

- Title:
  - `Record: 4096-Vocab + 4.0-MLP-mult + 0.085-WD + Simplifications — val_bpb 1.09785 (3-seed mean)`
- Key ideas:
  - much larger vocab
  - wider MLP
  - stronger weight decay
  - simplification of other moving parts
- Local portability:
  - moderate for `MLP_MULT` and `WEIGHT_DECAY`
  - weak for full 4096-vocab adjudication unless we rebuild local data/tokenizer

### `PR #1209`

- Title:
  - `Record: Full GPTQ + Score-First TTT + SLOT — val_bpb 1.1064 (3-seed mean)`
- Key ideas:
  - SLOT
  - score-first TTT
  - full GPTQ
- Local portability:
  - weak for exact quality ranking
  - useful as a reminder that `SLOT` remains live in the public frontier

### `PR #1105`

- Title:
  - `Record: Fused MLP (Triton+CUTLASS EVT) + Fast Causal N-Gram Tilt & Subword Certainty — 1.1052 BPB (3-seed mean)`
- Main stack ideas:
  - fused MLP kernels
  - fast causal n-gram tilt
  - MLP 3.5×
  - mixed int5/int6 quantization
  - AR self-generated GPTQ calibration
  - Brotli-11 compression
  - LR floor
- Local portability:
  - weak for kernels / n-gram / mixed GPTQ
  - moderate for `MLP 3.5×` and `LR floor`

### `PR #1204`

- Title:
  - `Record: ParallelResiduals + MiniDepthRecurrence, 1.1063 BPB`
- Key ideas:
  - parallel residual lanes starting in late layers
  - mini depth recurrence around middle layers
  - mixed quant + AR GPTQ inherited from `PR #1105`
- Local portability:
  - good for parallel residuals
  - moderate for mini depth recurrence
  - weak for mixed quant / GPTQ adjudication
- Current local action:
  - partial `parallel residuals` port in progress

### `PR #1217`

- Title:
  - `Non Record: MuonEq-R + Context-Only SLOT + QK_GAIN=5.0 — val_bpb 1.1027 (3-seed mean)`
- Key ideas:
  - MuonEq-R optimizer
  - `QK_GAIN_INIT=5.0`
  - Context-only SLOT
- Local portability:
  - good for `QK_GAIN_INIT=5.0`
  - weak-to-moderate for SLOT
  - weak for MuonEq-R until ported carefully
- Current local action:
  - cheap `QK_GAIN=5.0` signal-check experiment prepared

### `PR #965`

- Title:
  - `Architectural Record: 1.11837 BPB via KGIIR Trajectory Mixing`
- Key idea:
  - lightweight 4-tap causal temporal mixer before Q/K/V projection
- Local portability:
  - good
- Notes:
  - likely a later local experiment if `parallel residuals` and `QK gain` are not enough to validate harness sensitivity

## Local-portable vs local-nonportable

### Strong local-portable categories

- residual-path changes
- value-path changes
- gating changes
- small token mixers
- recurrence changes
- `QK_GAIN` / other architecture hyperparameters

### Weak local-portable categories

- fused kernels
- FlashAttention / Triton / CUTLASS wins
- full GPTQ export claims
- mixed bitwidth allocation quality claims
- n-gram / cache eval systems work

## Current working hypothesis

The local MLX harness should be expected to catch:

1. clear architecture wins
2. stable residual-path improvements
3. some hyperparameter wins
4. at least part of the `QK_GAIN` / residual / recurrence family now visible in April 1 PRs

It should *not* be expected to reliably rank:

1. systems throughput wins
2. pure export / quantization wins
3. eval-time cache machinery
4. full `SLOT` / scored-position / per-sample-delta leaderboard stacks

## Current local positive controls

1. `PR824 mimic` family
   - already proven locally useful
2. `PR1204` partial port
   - in progress
3. `PR1217` `QK_GAIN=5.0`
   - queued
4. `PR1218` style wider-MLP / stronger-WD simplification
   - likely next simple mutation if the current latest-PR wave gives signal
