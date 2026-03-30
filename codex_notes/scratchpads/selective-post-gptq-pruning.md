# Experiment Note

## Experiment

- Name: Selective post-GPTQ pruning
- Status: FAIL
- Owner: worker-selective-post-gptq-pruning
- Branch: `codex/selective-post-gptq-pruning`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/selective-post-gptq-pruning`
- Seed(s): `1337` for the first sequential screen
- Experiment-local trainer path(s):
  - `experiments/selective-post-gptq-pruning/train_gpt.py`
  - `experiments/selective-post-gptq-pruning/train_gpt_mlx.py`

## Hypothesis

- After GPTQ-style int8 export, zeroing the smallest-magnitude entries in large matrices may improve zlib compressibility more than it hurts roundtrip quality.

## Scope

- Files expected to change:
  - `experiments/selective-post-gptq-pruning/train_gpt.py`
  - `experiments/selective-post-gptq-pruning/train_gpt_mlx.py`
  - `experiments/selective-post-gptq-pruning/README.md`
- Local screen command(s):
  - `TRAIN_MLX_SCRIPT=experiments/selective-post-gptq-pruning/train_gpt_mlx.py POST_GPTQ_PRUNE_FRACTION=0.02 POST_GPTQ_PRUNE_MIN_NUMEL=16384 bash scripts/run_local_screen_mlx.sh`
- Remote run command(s):
  - `POST_GPTQ_PRUNE_FRACTION=0.02 POST_GPTQ_PRUNE_MIN_NUMEL=16384 RUN_ID=selective-post-gptq-pruning_remote ./.venv/bin/python experiments/selective-post-gptq-pruning/train_gpt_mlx.py`

## Progress

- Baseline for comparison: `codex_notes/coordination_live/baseline_benchmarks.md`
- Shared coordination entry: `codex_notes/coordination_live/experiment_board.md`
- New knobs:
  - `POST_GPTQ_PRUNE_FRACTION`
  - `POST_GPTQ_PRUNE_MIN_NUMEL`

## Local Screening

- Status: DONE
- Date:
- Log path:
- Artifact path(s):
- Throughput / wallclock:
- Val / BPB:
- Notes:
  - The trainer now zeroes small-magnitude entries only in large 2D quantized tensors before serializing the int8 artifact.
  - The pruning is intentionally conservative: it is disabled by default and only activates when `POST_GPTQ_PRUNE_FRACTION > 0`.
  - stronger local-screen rerun:
    - command: `SEED=1337 RUN_ID=selective_post_gptq_pruning_long_seed1337 POST_GPTQ_PRUNE_FRACTION=0.02 POST_GPTQ_PRUNE_MIN_NUMEL=16384 TRAIN_MLX_SCRIPT=experiments/selective-post-gptq-pruning/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh`
    - baseline on the same stronger harness: `2.15725007`, `13,736,236 bytes`
    - pruning result: `2.16040061`, `13,533,627 bytes`
    - pruned tensors: `55`
    - pruned entries: `1,802,411`
    - conclusion: saves about `202,609 bytes`, but the BPB regression is not worth it at this pruning fraction

## Promotion Decision

- Promote to remote: HOLD
- Reason: the longer local-screen rerun showed a quality regression that is not worth the size savings at the current pruning fraction.
- Remote priority: after the first local screen, promote only if the compressed artifact gets smaller without an obvious BPB regression.

## Remote Training

- Status: TODO
- Date:
- Machine / provider:
- Run identifier:
- Log path:
- Artifact path(s):
- Pre-quant:
- Post-quant:
- Speed / wallclock:
- Artifact size:
- Notes:

## Results Summary

- Pre-quant:
- Post-quant:
- Speed / wallclock:
- Artifact size:

## Conclusion

- Selective post-GPTQ pruning is implemented and measured.
- On the stronger default local-screen harness, the current `0.02` fraction is not a good trade.

## Next step

- Run the local screening command above, compare the post-quant artifact size and BPB against the baseline, then decide whether to promote to remote.
