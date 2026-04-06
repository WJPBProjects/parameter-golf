# Remote Preflight 2026-04-06

Purpose: avoid spending `8xH100` time on failures that can be caught locally.

## Candidate checks

Ran local `py_compile` and a tiny CPU PyTorch import / `GPT` instantiate / forward pass for:

- `late-value-embed-qk5`
- `embedding-skip-parallel-late`
- `compile-safe-late-qat`
- `parallelres-qkgain5`
- `xsa-all`

Result: all passed.

## Queue decision

Queue A is original-first:

1. `late-value-embed-qk5`
2. `embedding-skip-parallel-late`

Queue B is overflow:

1. `compile-safe-late-qat`
2. `parallelres-qkgain5`

`late-value-embed-legal-ttt` stays in overflow queue C because Legal-TTT is less novel and should not consume the first spend window.

## Caveat

Several remote candidate features do not exist in their MLX trainer copies, so a local MLX run would not test the actual remote hypothesis. For those branches, the useful local preflight is syntax/import/shape plus the remote wrapper's train-script and dataset/tokenizer checks.
