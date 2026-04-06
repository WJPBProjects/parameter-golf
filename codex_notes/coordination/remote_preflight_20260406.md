# Remote Preflight 2026-04-06

Purpose: avoid spending `8xH100` time on failures that can be caught locally.

## Candidate checks

Ran local `py_compile` for:

- `late-value-embed-qk5`
- `embedding-skip-parallel-late`
- `compile-safe-late-qat`
- `parallelres-qkgain5`
- `late-value-embed-legal-ttt`

Result: all passed.

Also ran local MLX runner smoke for:

- `late-value-embed-qk5`
  - `/Users/wulfie/code/parameter-golf-worktrees/late-value-embed-qk5/logs/preflight_late_value_embed_qk5_20260406_215133.txt`
- `embedding-skip-parallel-late`
  - `/Users/wulfie/code/parameter-golf-worktrees/embedding-skip-parallel-late/logs/preflight_embedding_skip_parallel_late_20260406_215152.txt`

Result: both passed. Caveat: the MLX copies do not fully exercise the CUDA-only remote mechanisms for these branches.

## Queue decision

Queue A is original-first:

1. `late-value-embed-qk5`
2. `embedding-skip-parallel-late`

Queue B is overflow:

1. `parallelres-qkgain5`
2. `compile-safe-late-qat`

`late-value-embed-legal-ttt` stays in overflow queue C because Legal-TTT is less novel and should not consume the first spend window.

## Caveat

Several remote candidate features do not exist in their MLX trainer copies, so a local MLX run does not fully test the actual remote hypothesis. For those branches, the useful local preflight is syntax plus the remote wrapper's train-script and dataset/tokenizer checks.
