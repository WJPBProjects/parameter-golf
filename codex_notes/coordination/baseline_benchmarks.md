# Baseline Benchmarks

Use this file to record the current baseline numbers that new experiments should
beat or at least compare against.

## Current local baseline

### `baseline_local_full_20260327_1540`

- Date: `2026-03-27`
- Commit: `ad3b943`
- Tree state: local working tree had uncommitted agent-side setup changes, but this run used the default `train_gpt_mlx.py` behavior with no dev-mode overrides.
- Machine: local Apple Silicon MacBook Pro (`Apple M4 Max`, `36 GB` unified memory)
- Command:
  - `RUN_ID=baseline_local_full_20260327_1540 ./.venv/bin/python train_gpt_mlx.py`
- Seed:
  - default `SEED=1337`
- Log:
  - `logs/baseline_local_full_20260327_1540.txt`
- Artifacts:
  - `logs/baseline_local_full_20260327_1540_mlx_model.npz`
  - `logs/baseline_local_full_20260327_1540_mlx_model.int8.ptz`
- Dataset note:
  - local run used the currently downloaded subset and logged `train_shards:10/195`

## Metrics

- Stop point:
  - `step:45/20000`
  - `train_time:606582ms`
  - `step_avg:13479.59ms`
- Pre-quant final validation:
  - `val_loss:6.2341`
  - `val_bpb:3.6922`
- Quantized roundtrip:
  - `val_loss:6.51445275`
  - `val_bpb:3.85822586`
  - `eval_time:354388ms`
- Artifact size:
  - `serialized_model_int8_zlib:5203412 bytes`
- Raw MLX model size:
  - `67212188 bytes`
- Approximate wallclock:
  - log file created `15:39:13`
  - log file finished `16:05:45`
  - about `26m32s` total elapsed including warmup, training, validation, serialization, and quantized roundtrip eval

## Interpretation

- This is the current trustworthy local MLX baseline on this machine.
- It is a good comparison point for future local MLX experiments that use the same machine and dataset subset.
- It is **not** directly comparable to the README's reported baseline score, because the README score is for the remote CUDA path on `1xH100`, not local MLX on the Mac.

## README comparison

- README local MLX section:
  - gives a small `mlx_smoke` example for local iteration
- README remote CUDA section:
  - says the `train_gpt.py` baseline on `1xH100` should land around `~1.2 val_bpb` with a compressed model size under `16MB`

That means:

- local MLX baseline here: `3.8582 val_bpb` post-quant roundtrip
- README remote baseline expectation: about `1.2 val_bpb`

This gap is expected because the hardware and training path are very different.

## What to compare against next

- For local screening:
  - compare new full local MLX runs against `val_bpb:3.85822586`
  - keep machine, shard subset, and command shape as stable as possible
- For remote promotion:
  - compare promoted runs against the remote README / leaderboard expectations instead

## Current longer local-screen baseline

### `baseline_long_seed1337`

- Date: `2026-03-27`
- Command:
  - `SEED=1337 RUN_ID=baseline_long_seed1337 bash scripts/run_local_screen_mlx.sh`
- Seed:
  - `1337`
- Log:
  - `logs/baseline_long_seed1337.txt`
- Artifacts:
  - `logs/baseline_long_seed1337_mlx_model.npz`
  - `logs/baseline_long_seed1337_mlx_model.int8.ptz`

## Longer local-screen metrics

- Train:
  - `step:800/800`
  - `train_time:225971ms`
  - `step_avg:282.46ms`
- Pre-quant capped validation:
  - `val_loss:3.5904`
  - `val_bpb:2.1573`
- Quantized roundtrip:
  - `val_loss:3.59037498`
  - `val_bpb:2.15725007`
  - `eval_time:21434ms`
- Artifact size:
  - `serialized_model_int8_zlib:13736236 bytes`

## Longer local-screen interpretation

- This is now the fair comparison point for the strengthened `run_local_screen_mlx.sh` harness.
- Use it for apples-to-apples comparisons against local experiment branches that are rerun on the same longer screen settings.

## New laptop longer local-screen baseline

### `baseline_long_new_laptop`

- Date: `2026-04-01`
- Command:
  - `SEED=1337 RUN_ID=baseline_long_new_laptop bash scripts/run_local_screen_mlx.sh`
- Seed:
  - `1337`
- Log:
  - `logs/baseline_long_new_laptop.txt`
- Artifacts:
  - `logs/baseline_long_new_laptop_mlx_model.npz`
  - `logs/baseline_long_new_laptop_mlx_model.int8.ptz`

## New laptop longer local-screen metrics

- Train:
  - `step:800/800`
  - `train_time:215827ms`
  - `step_avg:269.78ms`
- Pre-quant capped validation:
  - `val_loss:3.5873`
  - `val_bpb:2.1554`
- Quantized roundtrip:
  - `val_loss:3.58832782`
  - `val_bpb:2.15602005`
  - `eval_time:17947ms`
- Artifact size:
  - `serialized_model_int8_zlib:13720762 bytes`

## New laptop comparison vs previous longer local-screen baseline

- Speed:
  - old machine `step_avg:282.46ms`
  - new machine `step_avg:269.78ms`
  - delta: `-12.68ms` per step, about `4.5%` faster
- Quantized quality:
  - old machine `val_bpb:2.15725007`
  - new machine `val_bpb:2.15602005`
  - delta: `-0.00123002`
- Quantized eval time:
  - old machine `21434ms`
  - new machine `17947ms`
  - delta: `-3487ms`, about `16.3%` faster
- Artifact size:
  - old machine `13736236 bytes`
  - new machine `13720762 bytes`
  - delta: `-15474 bytes`

## New laptop interpretation

- The new laptop is a modest but real upgrade for the local MLX loop.
- The most defensible speed number is the training `step_avg`, which improved by about `4.5%`.
- Final quantized evaluation was faster too, by about `16%`.
- Quality is effectively unchanged, which is what we want for an apples-to-apples hardware comparison.
