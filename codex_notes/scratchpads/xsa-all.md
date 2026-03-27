# Experiment Note

## Experiment

- Name: XSA all layers
- Status: TODO
- Owner:
- Branch: `codex/xsa-all`
- Worktree:

## Hypothesis

- Expanding XSA from later layers to all layers may improve quality enough to justify any speed or artifact tradeoff.

## Scope

- Files expected to change:
  - `train_gpt.py`
  - `train_gpt_mlx.py`
- Local screen command(s):
- Remote run command(s):

## Progress

- Baseline for comparison: `codex_notes/coordination/baseline_benchmarks.md`
- Implemented `XSA_LAST_N` gating in both `train_gpt.py` and `train_gpt_mlx.py`.
- On this 9-layer baseline, `XSA_LAST_N=9` means all layers are XSA-active.
- Local screen command used:
  - `RUN_ID=xsa_all_screen_20260327_2 XSA_LAST_N=9 ITERATIONS=10 WARMUP_STEPS=2 TRAIN_BATCH_TOKENS=8192 VAL_LOSS_EVERY=0 VAL_BATCH_SIZE=524288 ./.venv/bin/python train_gpt_mlx.py`

## Local Screening

- Status: DONE
- Date: `2026-03-27`
- Log path: `logs/xsa_all_screen_20260327_2.txt`
- Artifact path(s):
  - `logs/xsa_all_screen_20260327_2_mlx_model.npz`
  - `logs/xsa_all_screen_20260327_2_mlx_model.int8.ptz`
- Throughput / wallclock:
  - `step:10/10 train_time:2958ms step_avg:295.78ms tok_s:26730`
- Val / BPB:
  - pre-quant `val_bpb:3.7018`
  - post-quant `val_bpb:3.70241482`
- Notes:
  - baseline comparison: `3.85822586` post-quant local benchmark
  - training is slower than baseline, but the scored post-quant BPB improved substantially
  - quantized artifact size increased to `7839700 bytes`, still under the 16MB cap

## Promotion Decision

- Promote to remote: `READY`
- Reason:
  - local post-quant BPB improved by about `0.1558` over the saved baseline
  - artifact stays under the 16MB limit
  - the change is isolated and reproducible on the local screen
- Remote priority: `HIGH`

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
  - next step should be a remote CUDA confirmation with the same `XSA_LAST_N=9` setting

## Results Summary

- Pre-quant: `6.2503 val_loss`, `3.7018 val_bpb`
- Post-quant: `6.25137234 val_loss`, `3.70241482 val_bpb`
- Speed / wallclock: `295.78ms` per step on the local screen
- Artifact size: `7839700 bytes`

## Conclusion

- XSA-all is a real improvement signal on the local MLX screen, but it costs some throughput and increases the compressed artifact size.
- Promote this to remote training.

## Next step

- Run the same `XSA_LAST_N=9` configuration on the remote CUDA path and compare against the current remote baseline stack.
