# NanoGPT and Adjacent Research Directions

Date: `2026-04-06`

## Main conclusion

- Plain `karpathy/nanoGPT` is useful as a baseline code style reference, but it is not the richest source of frontier tricks for Parameter Golf.
- The stronger idea source is:
  - `KellerJordan/modded-nanogpt`
  - `karpathy/nanochat`
  - a small set of recent small-model papers such as `nGPT` and small-model `MLA`

## What plain NanoGPT says

Source:

- `https://github.com/karpathy/nanoGPT`

What matters:

- it already treats `torch.compile` as a meaningful speed lever
- it explicitly calls out future work around:
  - rotary embeddings
  - ALiBi
  - better init
  - linear batch-size increase
  - more logging around network health

Assessment:

- useful sanity baseline
- not enough by itself for a strong new Parameter Golf direction

## What modded-nanogpt says

Source:

- `https://github.com/KellerJordan/modded-nanogpt`

Most relevant record-history ideas:

- Muon
- ReLU^2
- zero-init projections
- QK-norm
- untied embedding and head
- value and embedding skip connections
- logit softcap
- U-net skip pattern
- attention window warmup / sliding-window schedules
- value embeddings
- second input embedding
- EMA wrapper on Muon

Assessment for this repo:

- strongest transferable family is still the value-path family:
  - value residual
  - value embeddings
  - embedding skip / second input embedding
- the second strongest family is geometry / stabilization:
  - QK norm or gain changes
  - zero-init projection variants
  - EMA / optimizer wrappers
- several speedrun tricks are less relevant here because the benchmark is not "reach a fixed loss fastest" but "best compressed model in 10 minutes":
  - FlexAttention / context schedule work
  - MTP-like tricks
  - pure throughput kernel work unless it directly buys more train tokens in the fixed wallclock

## What nanochat says

Source:

- `https://github.com/karpathy/nanochat`

Useful signal:

- Karpathy explicitly says nanochat is inspired by `modded-nanogpt`
- the stated focus is improving small-model end-to-end performance by improving pretraining throughput and quality, not just making the code minimal

Assessment:

- use `nanochat` mainly as evidence that `modded-nanogpt`-style ideas are the live evolutionary branch of `nanoGPT`
- not the first repo to mine for Parameter Golf deltas

## Other literature worth taking seriously

### nGPT

Sources:

- `https://arxiv.org/abs/2410.01131`
- `https://github.com/NVIDIA/ngpt`

Claim:

- normalized Transformer on the hypersphere
- claims `4x` to `20x` fewer steps to comparable accuracy depending on sequence length

Assessment:

- interesting because the challenge is wallclock-limited
- risky because it is an invasive architecture/training change
- the public repo itself warns its implementation/precision story may distort the baseline comparison
- not a first-wave idea for expensive `8xH100` ranking

### MLA for small models

Sources:

- `https://arxiv.org/abs/2506.09342`
- `https://arxiv.org/abs/2502.14837`
- `https://arxiv.org/abs/2505.13544`

What stands out:

- small-model MLA + RoPE can cut KV memory meaningfully with small quality loss
- MHA-to-MLA adaptation papers suggest partial-RoPE and low-rank KV approximations are the practical path

Assessment:

- more interesting for inference/cache efficiency than for immediate Parameter Golf wins
- partial-RoPE and low-rank attention adapters may still be worth borrowing
- full MLA / MTLA is probably too invasive for the current run queue

## Recommended research queue

### Exploit first

- value embeddings on top of the current value-residual family
- second input embedding / embedding skip variants
- zero-init projection variants around the winning value-path branches
- QK norm / QK gain variants on top of strong value-path branches
- EMA wrapper / optimizer wrapper variants that do not explode code complexity

### Explore second

- lightweight nGPT-style normalization ablations
- partial-RoPE or low-rank KV ablations borrowed from MLA papers
- very small latent-attention hybrids only if they can be isolated cleanly

### Deprioritize for now

- graph / spline branches
- long-context scheduling tricks
- pure `1xH100` proxy optimization
- anything whose main benefit is inference-side cache speed without clear effect on compressed score

## Immediate implication

- The strongest external signal still points toward:
  - value-path additions
  - geometry / normalization stabilizers
  - optimizer wrappers
- The next novel branch family should probably be:
  - `value_residual + value_embedding`
  - `value_residual + second_input_embedding`
  - `value_residual + qk_norm_or_gain_variant`
