# Value-Path Frontier Memo (2026-04-02)

This note consolidates the two research sidecars launched during the `pr824_stacks_20260402`
local wave.

## Practical conclusion

- Keep the local search centered on the PR824 family:
  - value residual
  - attention gating
  - XSA window / soft-XSA variants
  - `QK_GAIN` neighborhood
  - KGIIR / lightweight temporal mixers
- Do not spend local MLX slots on SLOT, rANS, n-gram cache systems, or heavy GPTQ/export
  stacks until remote compute is available. Those may matter for leaderboard records, but
  they are poor local screening targets on this laptop.

## Highest-priority local experiments

1. `PR824 + KGIIR-lite`
   - Paper/PR source: PR #965 and Griffin-style gated recurrence literature
   - Hypothesis: PR824's value path and KGIIR's local temporal mixer may be complementary
     because one improves residual routing while the other improves short-range trajectory
     mixing before Q/K/V projection.
   - Status: already queued as `codex/pr824-kgiir-lite`.

2. `PR824 + soft XSA`
   - Paper/PR source: PR #1215
   - Hypothesis: soften the hard value-projection subtraction so the model can learn how
     much self-exclusion to keep, instead of hard-coding full XSA.
   - Status: already queued as `codex/pr824-soft-xsa`.

3. `PR824 + QK_GAIN neighborhood`
   - Paper/PR source: PR #1217
   - Hypothesis: `QK_GAIN=5.0` is locally useful only when stacked on the PR824 value/gate
     core; test nearby values before overfitting to a single lucky point.
   - Status: `codex/pr824-qkgain45`, `codex/pr824-qkgain5`, `codex/pr824-qkgain6`.

4. `PR824 + DiffAttn-lite`
   - Paper source: Differential Transformer
   - Hypothesis: a tiny second attention correction in late layers may sharpen retrieval
     without a large parameter increase.
   - Status: already queued as `codex/pr824-diffattn-lite`.

5. `PR824 + value-embedding-lite`
   - Paper/PR source: PR #1216
   - Hypothesis: a dedicated value embedding path may reinforce the same mechanism that is
     already winning locally via value residuals.
   - Status: branch bug fixed, clean rerun queued in `value-embedding-retry`.

## New explore ideas to prepare if current queued waves stall

- `PR824 + Softpick-lite`
  - Literature: Softpick + attention-sink papers
  - Start with a late-layer attention-score transform or sink penalty that keeps the
    implementation narrow enough for `train_gpt_mlx.py`.

- `PR824 + token-wise residual gates`
  - Literature: What Layers When
  - Add a tiny sigmoid gate before the attention and MLP residual adds in late blocks.

- `PR824 + tiny compressive memory slots`
  - Literature: Infini-attention
  - Prototype 1-2 learned memory slots injected into the decoder skip/value path.

- `Non-uniform layer capacity`
  - Literature: OpenELM
  - Reallocate MLP/head width toward later layers while keeping the 16MB artifact budget
    in mind.

## Working theory

- The dominant local mechanism is not XSA by itself.
- The strongest signal so far comes from giving later layers a better route back to the
  original token/value stream, then tuning attention-score sharpness around that route.
- That explains why:
  - `PR824 value-residual-only` keeps almost all of the full PR824 gain
  - `PR824 + QK_GAIN=5.0` is currently the best local branch
  - `XSA_LAST_N=4` remains good but does not beat XSA6
  - standalone `QK_GAIN=5.0` was a miss while the PR824-stacked version was a win

## Source pointers

- PR #824: GatedAttn + ValueResid + XSA6 + HedgeMixer + Legal TTT
- PR #1217: MuonEq-R + Context-Only SLOT + `QK_GAIN=5.0`
- PR #1216: XSA-all + value embeddings + EMA
- PR #1215: Soft XSA + LeakyReLU^2 + rANS
- PR #965: KGIIR trajectory mixing
- PR #1204: ParallelResiduals + MiniDepthRecurrence
- Value Residual Learning: `arXiv:2410.17897`
- Attention Residuals: `arXiv:2603.15031`
- Differential Transformer: `arXiv:2410.05258`
- Griffin: `arXiv:2402.19427`
- Softpick: `arXiv:2504.20966`
- Attention Sink: `arXiv:2410.10781`
- Infini-attention: `arXiv:2404.07143`
- OpenELM: `arXiv:2404.14619`
- xLSTM: `arXiv:2405.04517`
- HGRN2: `arXiv:2404.07904`
