# Frontier Shift: April 6, 2026

## Main point

The public neural-only frontier has moved beyond the older PR824-family value-path line.

The strongest clean public direction now looks more like:

- SP4096 / SP8192
- depth recurrence
- parallel residuals
- MuonEq-R or adjacent optimizer refinements
- QK gain around `5.0`
- stronger quant/compression stacks

This does **not** make our value-path evidence useless.
It means:

- value residual / value embedding is now best treated as a **candidate additive mechanism**
- not as the whole base stack

## Strong public signals

### PR #1334

- `SP4096 + Depth Recurrence + Parallel Residuals + MuonEq-R + QK-Gain 5.0`
- claimed `1.0897` 3-seed mean
- low legality risk versus TTT / SLOT / n-gram families

### PR #1331

- `MuonEq-R + 3-layer recurrence + WD=0.095 + MLR=0.022 + all-int6`
- claimed `1.0900` 3-seed mean

### PR #1394

- `SP8192 + GPTQ embeddings + depth recurrence + MuonEq-R + SDClip`
- claimed `1.08563` 5-seed mean
- notable because it reportedly removes value embeddings, which leaves room for a novel value-path restoration

## What this means for our strategy

### Do not center the run on

- PR824 mimic family as the main north star
- `1xH100` proxy ranking
- TTT / SLOT / n-gram families as first-wave submission bets

### Do center the run on

- remote-capable branches that can move toward:
  - parallel residuals
  - QK gain
  - recurrence-lite or shared-block reuse
- novel additions that may still be ours:
  - value embedding
  - second input embedding
  - lightweight value-path restoration on top of a stronger clean neural base

## Best current novel design idea

- `parallel residuals + QK gain 5.0 + novel value/embedding path`

This is the cleanest bridge between:

- our local evidence
- modded-nanogpt / nanochat style value embeddings
- the current parameter-golf frontier

## Immediate operational consequence

- build the shared `8xH100` reference curve first
- then spend remote budget on:
  - one or two remote-capable strong-stack candidates
  - not on the full older PR824 family
