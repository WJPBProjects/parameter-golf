# Literature Mixer / Residual Frontier (2026-04-02)

This note is for locally portable ideas only. It excludes papers whose main value is remote-only kernels, huge context, or fully custom runtime stacks.

## Ranked recent sources

### 1. Attention Residuals (2026)

- Source:
  - `arXiv:2603.15031`
- Core idea:
  - replace fixed residual accumulation with learned depth-wise attention over prior layer outputs
- Why it may matter here:
  - our strongest local winner is already a value/residual-path modification, so depth-wise residual routing is aligned with the current signal
- Minimal local port:
  - implement a tiny identity-biased late-layer version first, not full Block AttnRes
  - start from `hyperconnection-lite` or a `PR824` branch
- Candidate experiments:
  1. `hyperconnection-lite` confirm run
  2. `pr824 + tiny depth-wise residual mixer`
  3. learned 2-source residual router between current hidden state and one saved early-layer state

### 2. Griffin: Mixing Gated Linear Recurrences with Local Attention for Efficient Language Models (2024)

- Source:
  - `arXiv:2402.19427`
- Core idea:
  - hybrid gated linear recurrence + local attention
- Why it may matter here:
  - gives a lightweight recurrence/mixer family without replacing every block with a heavy SSM
- Minimal local port:
  - add one small gated recurrence branch in late layers only, then keep normal attention path intact
- Candidate experiments:
  1. tiny late-layer gated recurrence side branch
  2. local attention window reduction plus recurrence branch
  3. PR824 value-residual plus one recurrence branch

### 3. Transformers are SSMs / Mamba-2 (2024)

- Source:
  - `arXiv:2405.21060`
- Core idea:
  - structured state-space duality and a faster Mamba-2 layer
- Why it may matter here:
  - suggests small selective-state mixers may be worth one lightweight hybrid insertion, but not a full architecture rewrite
- Minimal local port:
  - one tiny state-mixer block in the middle or late stack, compared against `parallel_residuals_pr1204`
- Candidate experiments:
  1. one-state-mixer block around layer 4 or 5
  2. state-mixer side branch added only to value path
  3. PR824 mimic plus one tiny state-mixer block

### 4. xLSTM: Extended Long Short-Term Memory (2024)

- Source:
  - `arXiv:2405.04517`
- Core idea:
  - exponential gating and modified scalar/matrix memory inside an LSTM-style block
- Why it may matter here:
  - the model family emphasizes compact gating and residual-stack compatibility
- Minimal local port:
  - borrow only the stabilised exponential gate form, not the full xLSTM block
- Candidate experiments:
  1. swap one branch gate to an xLSTM-style exponential gate
  2. use xLSTM-style gate normalization for `attn_gate`
  3. tiny scalar-memory mixer in late layers only

### 5. Kimi Linear: An Expressive, Efficient Attention Architecture (2025)

- Source:
  - `arXiv:2510.26692`
- Core idea:
  - hybrid Kimi Delta Attention + MLA, with channelwise gated delta-rule memory
- Why it may matter here:
  - public Parameter Golf winners now repeatedly use value/residual/memory-path tricks, which is directionally consistent with KDA-style ideas
- Minimal local port:
  - do not try a full KDA layer first
  - instead, test a tiny gated finite-state value-memory side branch
- Candidate experiments:
  1. additive one-state value memory updated from each token
  2. gate-controlled delta update on a compressed value projection
  3. PR824 value residual plus a tiny KDA-inspired memory term

### 6. M2RNN: Non-Linear RNNs with Matrix-Valued States for Scalable Language Modeling (2026)

- Source:
  - `arXiv:2603.14360`
- Core idea:
  - one or a few matrix-state recurrent layers can outperform Gated DeltaNet hybrids, with small throughput cost
- Why it may matter here:
  - if one recurrent layer is enough to help, a minimal hybrid insertion might be locally testable
- Minimal local port:
  - one late-layer matrix-state branch with very small state rank
- Candidate experiments:
  1. one tiny matrix-state mixer replacing one late-layer MLP branch
  2. matrix-state mixer as an additive side path only
  3. matrix-state mixer only every other step / layer to cap cost

## What to queue next from this note

Priority:

1. `hyperconnection-lite`
2. one `PR824 + tiny depth-router` variant
3. one `PR824 + tiny gated recurrence side branch` variant

Do **not** queue all six source families at once. Keep the overnight budget focused on one exploit family plus one explore family.
