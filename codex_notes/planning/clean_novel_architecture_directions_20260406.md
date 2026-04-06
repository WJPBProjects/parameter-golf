# Clean Novel Architecture Directions

Date: `2026-04-06`

Scope: candidate Parameter Golf stack designs that avoid n-gram/cache leakage families and avoid straight duplicate PR stacks. These are based on the current April 2026 frontier PRs plus this repo's local/remote notes.

## Current frontier read

Public clean neural frontier signals:

- PR #1334: `SP4096 + depth recurrence + parallel residuals + MuonEq-R + QK-Gain 5.0`, `1.0897` 3-seed mean.
- PR #1331: `MuonEq-R + 3-layer recurrence + WD=0.095 + MLR=0.022 + all-int6`, `1.0900` 3-seed mean.
- PR #1394: `SP8192 + GPTQ embeddings + depth recurrence + MuonEq-R + SDClip`, `1.08563` 5-seed mean; explicitly removes value embeddings.
- PR #1332: `SP4096 + Polar Express NS + MuonEq-R + WD=0.090 + XSA all layers`, `1.0959`, closed.
- PR #1420: triple loop + fused kernels + parallel residuals + n-gram tilt, `1.08014`; n-gram tilt is out of scope here.

Avoid as submission anchors:

- n-gram/cache/tilt families, even if claimed legal.
- straight PR #1334/#1331/#1394/#1332/#1420 reimplementations.
- old PR824-like value-residual clone stacks; use value-path evidence as ingredient only.

## Candidate A: `sp8192-loop-ve-parallel`

Stack:

- Start from an SP8192 recurrent/SDClip-style base similar in shape to PR #1394, but add a narrow late value embedding stream.
- Recurrence: loop layers 4-5 in the PR #1394/#1420 neighborhood.
- Residual topology: parallel residuals in late decoder blocks, starting around layer 7.
- Geometry: QK gain 5.0 or row-normalized Muon/QK-gain stack.
- Novel addition: `VE_DIM=64-128` value embedding injected only into attention value stream for late layers, with per-layer learned gates initialized near zero.

Why it is distinct:

- PR #1394 explicitly removes value embeddings; this tests a targeted restoration rather than copying it.
- PR #1334 has recurrence + parallel residuals + QK gain, but no narrow late value-embedding stream.
- PR #1331 focuses on 3-layer recurrence and WD/LR synergy, not value/embedding-path reinjection.
- PR #1332 is XSA + optimizer/WD, not recurrence + value path.
- PR #1420 adds n-gram tilt and fused kernels; this excludes n-gram/cache behavior and changes the model path.

Minimal implementation delta:

- Add `VE_ENABLED`, `VE_DIM`, `VE_LAYERS`, and optional `VE_GATE_INIT`.
- Add a factorized embedding `Embedding(vocab, VE_DIM) -> Linear(VE_DIM, model_dim)` or direct `Embedding(vocab, model_dim)` if artifact budget permits.
- In selected late attention blocks, add the projected value embedding to the value tensor or to the attention output via `gate[layer] * ve`.
- Keep gates as scalar/vector parameters trained with Adam scalar group.

## Candidate B: `progressive-loop-pr-qk`

Stack:

- Keep the frontier recurrence motif, but change loop activation from a hard start to a compile-safe progressive loop gate.
- Use layers 4-5 as the main loop pair, but blend the extra pass through a schedule or learned gate:
  - `x = x + loop_gate(progress) * (loop_block(x) - x)`
- Add late parallel residuals and QK gain 5.0.

Why it is distinct:

- PR #1334 uses depth recurrence layers 4-5 starting at a fixed training step and parallel residuals from layer 7.
- PR #1331 extends to a 3-layer recurrence set plus WD/LR tuning.
- PR #1394 loops layers 4-5 twice with simpler implementation.
- PR #1420 changes number of loop passes and activates looping earlier, but does not make the loop a smooth/learned compile-safe blend.
- PR #1332 does not use recurrence.

Minimal implementation delta:

- Add envs `RECUR_PROGRESSIVE=1`, `RECUR_LAYERS=4,5`, `RECUR_START_FRAC`, `RECUR_RAMP_FRAC`, `RECUR_GATE_INIT`.
- Pass a tensor/buffer progress value into the model or update a module buffer outside the compiled region to avoid recompilation.
- Replace the extra recurrence pass with a gated interpolation between no-loop and looped outputs.
- Use existing parallel residual and QK-gain wiring where available.

## Candidate C: `embedding-skip-parallel-late`

Stack:

- Add a second narrow input embedding stream that is injected into late blocks, not into eval-time cache state.
- Combine with late parallel residual lanes and QK gain 5.0.
- Optional: route the second embedding into the MLP lane only, while attention keeps the normal representation.

Why it is distinct:

- PR #1394 removes value embeddings and does not introduce a second input embedding skip.
- PR #1334/#1331 focus on recurrence, QK gain, MuonEq-R, and quant/compression rather than embedding-path routing.
- PR #1332 uses XSA all layers instead of an embedding skip path.
- PR #1420 discusses skip gates in a recurrent architecture and adds n-gram tilt; this candidate is a direct token-embedding side channel inside the fixed predictor, not an eval cache or tilt.

Minimal implementation delta:

- Add `SKIP_EMB_ENABLED`, `SKIP_EMB_DIM=64-128`, `SKIP_EMB_LAYERS=6,7,8,9,10`, and `SKIP_EMB_TO=mlp|residual|attn`.
- Add factorized second embedding `Embedding(vocab, SKIP_EMB_DIM)` plus projection.
- In selected parallel-residual blocks, add `gate[layer] * skip_proj(skip_emb(input_ids))` to the MLP branch input or residual stream.
- Keep gate init near zero to make it a safe additive path.

## Candidate D: `loop-protected-qaware`

Stack:

- Keep the clean recurrent/parallel-residual/QK-gain base, but make loop-layer quantization treatment asymmetric.
- Protect only loop-sensitive matrices, especially value projections and MLP output projections in layers 4-5.
- Pair with late QAT or noisy QAT only for recurrent layers.

Why it is distinct:

- PR #1331 uses all-int6 plus WD/LR synergy; this uses layer-specific recurrence-aware protection.
- PR #1394 uses SDClip/GPTQ embeddings; this targets loop-layer error amplification specifically.
- PR #1420 reports loop-layer sensitivity in its analysis and uses n-gram tilt/fused kernels; this candidate operationalizes mixed protection without n-gram/cache behavior.
- PR #1334 is full GPTQ int6; this uses recurrence-aware bit/clip allocation.
- PR #1332 is optimizer/XSA-oriented.

Minimal implementation delta:

- Add export-time matrix policy keyed by parameter name:
  - loop layers: wider SDClip, int7, or protected GPTQ for `blocks.4/5.*v_proj*`, `blocks.4/5.*out_proj*`, and MLP down/up matrices.
  - non-loop layers: compensate with slightly tighter clip or lower bit budget if needed.
- Add optional late QAT/noisy-QAT for loop layers only during the final `10-20%` of wallclock.
- Log per-group compressed size and post-quant penalty.

## Priority

Recommended order:

1. `sp8192-loop-ve-parallel`
2. `embedding-skip-parallel-late`
3. `progressive-loop-pr-qk`
4. `loop-protected-qaware`

Rationale:

- The first two are the cleanest way to combine this repo's value-path signal with the current recurrence/parallel-residual frontier.
- The third is a plausible recurrence novelty that may reduce the abrupt-start tax.
- The fourth is likely valuable but more quantization-policy than architecture, so it is best paired with a working architecture rather than treated as the first remote shot.
