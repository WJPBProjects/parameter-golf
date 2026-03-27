# TODO

## Understand

- Custom Muon Optimizer
- Tied embeddings by default
- Grouped-query attention with fewer KV heads
- ReLU^2 MLP instead of GELU/SiLU
- RoPE
- LeakyReLU^2
- Encoder/decoder-style skip reuse across the stack
- Learned per-channel residual/attention/MLP scales

## Experiment

- Requests for PR examples to understand
  - Flash attention
  - 1-bit quantization
  - Ternary quantization
  - JEPA
  - Text diffusion
  - H-net tokenization
  - Universal transformer
  - Megakernels
  - State-space models
  - E2E TTT
  - Super long context for evaluation or training
  - Learning adapters on random linear maps
- SplineConv hybrid local graph branch (exploratory, lower priority than GPTQ/XSA/calibration)
