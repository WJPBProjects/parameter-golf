# External small-model / nanoGPT-adjacent ideas

Sources reviewed:
- [modded-nanogpt](https://github.com/KellerJordan/modded-nanogpt)
- [nanochat](https://github.com/karpathy/nanochat)
- [nGPT](https://github.com/NVIDIA/ngpt)

Shortlist for parameter-golf:

1. Late value embedding reinjection
   - Mechanism: add a small learned embedding stream that is mixed into attention values in the late blocks, with an optional gate.
   - Why it is interesting: `modded-nanogpt` explicitly lists "extra embeddings which are mixed into the values in attention layers" and "additional gating on value embeddings and skip connection" as part of the speedrun stack. That aligns with our local signal that value-path changes mattered more than attention-only tweaks.
   - Novelty warning: this is close to our already-running `codex/late-value-embed-qk5` and the earlier PR824-family value-residual experiments. Only worth more spend if we change placement, gating, or layer coverage enough to be a different mechanism.

2. Embedding skip connections into all blocks
   - Mechanism: add a direct embedding-to-block skip path, possibly with a second skip from an intermediate block range.
   - Why it is interesting: the `modded-nanogpt` README calls out "skip connections from embedding to every block as well as from block 3 to 6". `nanochat` also says it borrows heavily from `modded-nanogpt` for pretraining.
   - Novelty warning: this is likely adjacent to our `parallel residuals` / `hyperconnection` branches and may duplicate ideas already explored in spirit. Treat it as a reparameterization or placement sweep, not a clean new family.

3. QK geometry stack: QK norm / gain / softcap / zero-init projections
   - Mechanism: combine a conservative QK normalization or gain setting with softcapped logits and zero-init projections where they are cheap.
   - Why it is interesting: `modded-nanogpt` lists "Rotary embeddings, QK-Norm, and ReLU²", "FP8 matmul for head, and asymmetric rescale and softcap logits", and "initialization of projections to zero". `nGPT` also pushes a normalized-transformer framing.
   - Novelty warning: we already swept several `QK_GAIN` variants locally, so a plain gain-only run is mostly duplicate. This becomes interesting only as a stack with a value-path change or a different normalization regime.

4. Muon wrapper / EMA / schedule shaping
   - Mechanism: keep the base model fixed but change the optimizer wrapper, especially Muon momentum/EMA, weight-decay schedule, or batch/sequence schedules.
   - Why it is interesting: `nanochat` explicitly uses AdamW + Muon and maintains a speedrun leaderboard; `modded-nanogpt` also shows a long optimizer/schedule stack. These are often cheap to test and can amplify a good architecture.
   - Novelty warning: this is a strong systems lane, not a fresh model idea. Good if paired with a winner; weak as a standalone novelty claim.

5. nGPT-style hypersphere normalization
   - Mechanism: move the transformer toward normalized representations, with normalized hidden states and the architecture changes from nGPT.
   - Why it is interesting: `nGPT` claims faster convergence and is explicitly built on nanoGPT with normalized transformer layers. This is the most distinct external architecture candidate in the set.
   - Novelty warning: this is invasive and likely too far from our current training stack to be the first 8xH100 shot. It is a medium-risk explore lane, not a near-term submission default.

Practical read:
- Best near-term candidate from the external ecosystem is still the value-path family, but only if we make it meaningfully different from what we already ran.
- Best medium-risk explore candidate is nGPT-style normalization.
- Best low-risk stackable candidate is optimizer/schedule shaping around a strong base.

Do not repeat:
- plain QK-gain-only sweeps
- value-residual-only re-runs without a structural change
- embedding-skip ideas that are just parallel residuals with new names
