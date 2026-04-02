# Frontier Refresh (2026-04-02)

This memo is for the main agent’s overnight queue. It is intentionally biased
toward ideas that should still produce a directional signal under local MLX
training, while clearly marking remote-only ideas.

## Top public PR ideas to copy or ablate

| PR idea | Why it matters | Likely code locus | Local MLX signal? |
|---|---|---|---|
| `#1216` XSA-all + value embeddings + EMA | Extends the current strongest family: residual/value-path modifications plus stronger XSA coverage. | `experiments/*/train_gpt_mlx.py`, attention/value path, XSA config, embedding path | Good |
| `#1215` soft XSA + LeakyReLU^2 + rANS | Softened exclusion attention and a strong activation tweak may be locally testable; rANS is remote/export-only. | attention score transform, MLP activation; skip rANS locally | Good for soft XSA / activation, weak for rANS |
| `#1217` `QK_GAIN=5.0` + MuonEq-R + context-only SLOT | `QK_GAIN` is a cheap local knob; MuonEq-R and SLOT are likely remote-heavy but still worth lightweight ports. | config constants, optimizer, eval-time context adapter | Good for QK gain, moderate for MuonEq-R, weak for SLOT |
| `#1218` 4K vocab + 4x MLP + stronger WD | The local 4x-MLP partial port was too large/slow, but smaller-width and stronger-WD variants are still worth a constrained sweep. | model width/MLP multiplier, optimizer WD, tokenizer/data only if changing vocab | Good for width/WD, weak for 4K vocab without retokenized data |
| `#1219` window attention + mixed sequence lengths | Could recover speed while preserving quality if combined with value residual; mixed seq-len is likely more CUDA-sensitive. | attention mask/window logic, dataloader seq-len schedule | Moderate |
| `#1204` ParallelResiduals + mini depth recurrence | Partial parallel residuals already had local signal; a PR824-stacked version is the obvious next ablation. | block residual topology, late-layer recurrence side path | Good |
| `#1105` MLP 3.5x + n-gram tilt + mixed int5/int6 + AR GPTQ calibration | The architecture-width part is local-testable; n-gram tilt and export/quant stack are remote-only but strategically important. | MLP multiplier, eval logits postprocess, export/GPTQ pipeline | Moderate for MLP width, weak for the rest |
| `#965` KGIIR trajectory mixing | `KGIIR-lite` just won locally, so this is now a real branch family instead of speculative novelty. | tiny causal temporal mixer before Q/K/V projection | Good |
| `#932` CoDA differential attention | Differential attention may reduce sink/overfocus and is a compact attention-side mutation with manageable implementation cost. | attention score computation and head layout | Moderate |
| `#974` random linear map adapter projections | Very small artifact footprint and a clean adapter-like mechanism; likely easy to test as a low-rank/random-feature side branch. | embedding/input projection and adapter branch | Moderate |

## Top recent literature ideas to test

| Paper idea | Why it matters | Likely code locus | Local MLX signal? |
|---|---|---|---|
| Value Residual Learning / ResFormer (`arXiv:2410.17897`) | This directly matches the current PR824 result: the value-residual path is the main local winner and should be systematically swept. | attention value path, residual/value blending coefficients | Good |
| Attention Residuals (`arXiv:2603.15031`) | Learned depth-wise residual aggregation is a principled generalization of the local AttnRes-lite win and should be tested in tiny late-layer form first. | block residual routing across saved hidden states | Good |
| KGIIR trajectory mixing (`PR #965` architecture lineage) | A tiny pre-attention temporal mixer just showed a meaningful local gain and should now be stacked with PR824/value residual. | pre-QKV sequence mixer | Good |
| Kimi Linear / KDA (`arXiv:2510.26692`) | Full KDA is too big a rewrite, but a tiny gated value-memory side path may capture the useful part without replacing attention. | value-path side memory branch | Moderate |
| Griffin (`arXiv:2402.19427`) | A late-layer gated recurrence branch is a compact alternative to full SSM rewrites and may compose with local attention + value residual. | late-layer recurrence side path | Moderate |
| xLSTM (`arXiv:2405.04517`) | Borrow only the gate form/normalization, not the whole block; this is a low-risk way to improve residual/value gates. | `attn_gate` or value-branch gate parameterization | Moderate |
| Differential Transformer (`arXiv:2410.05258`) | Two-softmax subtraction is a direct attention-score mutation; a minimal single-layer or late-layer version should be locally screenable. | attention logits and output scaling | Moderate |
| Multi-Head Latent Attention / MLA (`arXiv:2405.04434`, `arXiv:2506.02523`) | Latent KV compression is attractive under an artifact cap, but quality/speed tradeoffs may only become obvious after a careful tiny local port. | Q/K/V projection factorization and cache/value path | Weak-to-moderate locally |
| MoHD (`arXiv:2412.05644`) | Hidden-dimension sparsity suggests a gated tail-MLP branch, which is exactly what `mohd-lastmlp-lite` is probing. | late MLP channel gating / split paths | Moderate |
| Softpick (`arXiv:2504.20966`) | A rectified softmax replacement could mitigate attention sinks with a small code delta and no big parameter increase. | attention probability transform | Moderate |
| BitNet b1.58 (`arXiv:2402.17764`) | Strategically important for compression, but likely a poor local MLX signal unless implemented as a tiny fake-quant/ternary probe first. | weight quantization path, fake-quant training hooks | Weak locally, remote/export stronger |

## Five concrete next branch ideas

1. `codex/pr824-kgiir-lite`
   - Hypothesis: KGIIR-lite’s temporal mixer is complementary to the PR824 value/gate stack and should beat PR824 mimic alone.

2. `codex/pr824-attnres-lite`
   - Hypothesis: a tiny late-layer depth-wise residual router on top of PR824/value-residual will improve BPB more than AttnRes-lite alone.

3. `codex/pr824-value-embedding-lite`
   - Hypothesis: a tiny learned value-embedding reinjection path will capture part of the `#1216` signal without blowing the artifact budget.

4. `codex/pr824-soft-xsa`
   - Hypothesis: softening XSA’s hard exclusion in the PR824 stack will preserve the value-residual gain while reducing attention brittleness.

5. `codex/pr824-diffattn-lite`
   - Hypothesis: a single late-layer differential-attention head group can improve selectivity and stack with value residual at modest cost.

## Near-term recommendation

- Keep `PR824 mimic` as the positive control.
- Exploit first:
  - `pr824-kgiir-lite`
  - `pr824-attnres-lite`
  - `pr824-value-embedding-lite`
- Explore second:
  - `pr824-soft-xsa`
  - `pr824-diffattn-lite`
- Deprioritize for now:
  - full SLOT / n-gram cache systems
  - full KDA / MLA rewrites
  - full BitNet training
  - full rANS/export-stack work

## Public source anchors

- GitHub pull list snapshot:
  - `https://github.com/openai/parameter-golf/pulls?q=is%3Apr+sort%3Aupdated-desc`
- Papers:
  - `https://arxiv.org/abs/2410.17897`
  - `https://arxiv.org/abs/2603.15031`
  - `https://arxiv.org/abs/2510.26692`
  - `https://arxiv.org/abs/2402.19427`
  - `https://arxiv.org/abs/2405.04517`
  - `https://arxiv.org/abs/2410.05258`
  - `https://arxiv.org/abs/2405.04434`
  - `https://arxiv.org/abs/2506.02523`
  - `https://arxiv.org/abs/2412.05644`
  - `https://arxiv.org/abs/2504.20966`
  - `https://arxiv.org/abs/2402.17764`
