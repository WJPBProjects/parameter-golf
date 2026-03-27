# Experiment Note

## Experiment

- Name: LeakyReLU slope sweep
- Status: DONE
- Owner: main-agent
- Branch: `codex/leakyrelu-slope-sweep`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/leakyrelu-slope-sweep`
- Seed(s): `1337`

## Hypothesis

- The current nonlinearity is promising enough that slope sweeps may buy cheap quality gains with little implementation risk.

## Scope

- Files expected to change:
  - `train_gpt.py`
  - `train_gpt_mlx.py`
- Local screen command(s):
  - `LEAKY_RELU_NEGATIVE_SLOPE=0 ITERATIONS=2 WARMUP_STEPS=1 DEV_VAL_MAX_BATCHES=4 RUN_ID=leakyrelu_sweep_zero bash scripts/run_local_screen_mlx.sh`
  - `LEAKY_RELU_NEGATIVE_SLOPE=0.05 ITERATIONS=2 WARMUP_STEPS=1 DEV_VAL_MAX_BATCHES=4 RUN_ID=leakyrelu_sweep_nonzero bash scripts/run_local_screen_mlx.sh`
- Remote run command(s):
  - `LEAKY_RELU_NEGATIVE_SLOPE=... RUN_ID=... torchrun --standalone --nproc_per_node=1 train_gpt.py`

## Progress

- Baseline for comparison: `codex_notes/coordination/baseline_benchmarks.md`
- Goal: confirm the env-var-controlled LeakyReLU^2 path preserves the baseline at slope `0.0`.
- Then run one small nonzero slope locally to check for any immediate signal.
- Implementation: slope now threads through both `train_gpt.py` and `train_gpt_mlx.py` via `LEAKY_RELU_NEGATIVE_SLOPE`.
- Verification: both `0.0` and `0.05` local-screen runs completed successfully.

## Local Screening

- Status: PASS
- Date:
- Seed(s): `1337`
- Log path:
- Artifact path(s):
- Throughput / wallclock:
- Val / BPB:
- Notes: both smoke runs completed; `0.0` preserved the baseline path and `0.05` ran cleanly with the same shape.

## Promotion Decision

- Promote to remote: HOLD
- Reason: this is a valid parameterized sweep path, but the current evidence is only a functional/local smoke. No meaningful quality delta yet.
- Remote priority:

## Remote Training

- Status:
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

- The slope sweep knob is implemented and verified.
- Keep it on hold until a longer local/full run or remote confirmation shows a real BPB difference.

## Next step

- If promoting later, run a longer local-screen sweep over a small slope grid before spending remote compute.
