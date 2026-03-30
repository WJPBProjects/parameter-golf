# Experiment Note

## Experiment

- Name: XSA all layers
- Status: PASS
- Owner: `main-agent`
- Branch: `codex/xsa-all`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/xsa-all`

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
  - rerun on the stronger default local-screen harness:
    - command: `SEED=1337 RUN_ID=xsa_all_long_seed1337_v2 XSA_LAST_N=9 TRAIN_MLX_SCRIPT=experiments/xsa-all/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh`
    - baseline on the same stronger harness: `2.15725007`
    - `xsa-all` on the stronger harness: `2.15552024`
    - artifact size: `13,743,183 bytes`
    - conclusion: still positive, but only by about `0.00173 val_bpb`, so the effect is much smaller than the earlier short-screen result suggested

## Promotion Decision

- Promote to remote: `HOLD`
- Reason:
  - the stronger longer-harness rerun still beats baseline, but only narrowly
  - that leaves too little margin to promote confidently from local signal alone
- Remote priority: `medium`

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
- Stronger local-screen rerun:
  - Pre-quant: `3.5855 val_loss`, `2.1543 val_bpb`
  - Post-quant: `3.58749597 val_loss`, `2.15552024 val_bpb`
  - Speed / wallclock: `281.78ms` per step
  - Artifact size: `13743183 bytes`

## Conclusion

- XSA-all is a real improvement signal on the local MLX screen, but it costs some throughput and increases the compressed artifact size.
- On the stronger default local-screen harness, the gain is still real but much smaller.
- Keep it as a candidate, but not as confidently as the earlier shorter screen implied.

## Next step

- Run the same `XSA_LAST_N=9` configuration on the remote CUDA path and compare against the current remote baseline stack.
