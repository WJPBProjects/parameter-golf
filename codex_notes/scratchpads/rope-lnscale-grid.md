# Experiment Note

## Experiment

- Name: RoPE + LN-scale grid
- Status: FAIL
- Owner: `worker-rope-lnscale-grid`
- Branch: `codex/rope-lnscale-grid`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/rope-lnscale-grid`
- Seed(s): `1337` for screening
- Experiment-local trainer path(s):
  - `experiments/rope-lnscale-grid/train_gpt.py`
  - `experiments/rope-lnscale-grid/train_gpt_mlx.py`

## Hypothesis

- Partial RoPE and per-layer scale initialization should compose better than tuning either knob alone, especially on the local MLX screening path.

## Scope

- Files expected to change:
  - `experiments/rope-lnscale-grid/train_gpt.py`
  - `experiments/rope-lnscale-grid/train_gpt_mlx.py`
  - `experiments/rope-lnscale-grid/README.md`
- Local screen command(s):
  - `ROPE_DIM=16 LN_SCALE_INIT=inv_sqrt TRAIN_MLX_SCRIPT=experiments/rope-lnscale-grid/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh`
  - Grid values to compare: `ROPE_DIM={8,16,24,32}` and `LN_SCALE_INIT={ones,inv_sqrt,inv_linear}`
- Remote run command(s):
  - `ROPE_DIM=16 LN_SCALE_INIT=inv_sqrt RUN_ID=rope-lnscale-grid_remote ./.venv/bin/python experiments/rope-lnscale-grid/train_gpt_mlx.py`

## Progress

- Baseline for comparison: `codex_notes/coordination_live/baseline_benchmarks.md`
- Implementation status: experiment-local trainers updated and syntax-checked.

## Local Screening

- Status: DONE
- Date:
- Log path:
- Artifact path(s):
- Throughput / wallclock:
- Val / BPB:
- Notes:
  - stronger local-screen rerun for the first grid point:
    - command: `SEED=1337 RUN_ID=rope_lnscale_grid_long_seed1337 ROPE_DIM=16 LN_SCALE_INIT=inv_sqrt TRAIN_MLX_SCRIPT=experiments/rope-lnscale-grid/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh`
    - baseline on the same stronger harness: `2.15725007`
    - rope grid first point: `2.17965799`
    - artifact size: `13510116 bytes`
    - conclusion: this first point is clearly worse than baseline, though a broader grid could still reveal a better corner

## Promotion Decision

- Promote to remote: HOLD
- Reason: the first screened grid point regressed badly, so this branch is not worth promoting without a more convincing alternate point.
- Remote priority: low until the local grid shows a clear improvement over the saved baseline.

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

- Experiment-local RoPE and scale knobs are ready for sequential local screening.
- The first screened point (`ROPE_DIM=16`, `LN_SCALE_INIT=inv_sqrt`) is a clear regression on the stronger local-screen harness.

## Next step

- Only revisit this branch if there is a strong reason to believe a different grid point changes the conclusion.
