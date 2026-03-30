# Experiment Note

## Experiment

- Name: SplineConv hybrid
- Status: HOLD
- Owner: worker-splineconv-hybrid
- Branch: `codex/splineconv-hybrid`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/splineconv-hybrid`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/splineconv-hybrid/train_gpt.py`
  - `experiments/splineconv-hybrid/train_gpt_mlx.py`

## Hypothesis

- A tiny spline-inspired causal token mixer can provide cheap local graph-style structure without adding much parameter or artifact overhead.
- This branch is intentionally conservative: it inserts the local mixer only on decoder-side blocks by default, so the first sequential run checks for signs of life rather than forcing a full architecture rewrite.

## Scope

- Files expected to change:
  - `experiments/splineconv-hybrid/train_gpt.py`
  - `experiments/splineconv-hybrid/train_gpt_mlx.py`
  - `experiments/splineconv-hybrid/README.md`
- Local screen command(s):
  - `TRAIN_MLX_SCRIPT=experiments/splineconv-hybrid/train_gpt_mlx.py SPLINE_LAYER_MODE=decoder SPLINE_RADIUS=4 SPLINE_NUM_KNOTS=4 bash scripts/run_local_screen_mlx.sh`
- Remote run command(s):
  - `SPLINE_LAYER_MODE=decoder SPLINE_RADIUS=4 SPLINE_NUM_KNOTS=4 ./.venv/bin/python experiments/splineconv-hybrid/train_gpt.py`

## Progress

- Baseline for comparison: `codex_notes/coordination_live/baseline_benchmarks.md`
- Implementation approach:
  - add a small `SplineMix` module in both trainers
  - keep it experiment-local under `experiments/splineconv-hybrid/`
  - keep the root trainers untouched

## Local Screening

- Status: DONE
- Date:
- Seed(s): `1337`
- Log path:
- Artifact path(s):
- Throughput / wallclock:
- Val / BPB:
- Notes:
  - stronger local-screen rerun:
    - command: `SEED=1337 RUN_ID=splineconv_hybrid_long_seed1337 SPLINE_LAYER_MODE=decoder SPLINE_RADIUS=4 SPLINE_NUM_KNOTS=4 TRAIN_MLX_SCRIPT=experiments/splineconv-hybrid/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh`
    - baseline on the same stronger harness: `2.15725007`
    - spline hybrid: `2.15680018`
    - artifact size: `13783464 bytes`
    - conclusion: essentially flat, maybe a hair better, but far too small a margin to treat as real yet

## Promotion Decision

- Promote to remote: HOLD
- Reason: it stayed numerically stable and nearly matched baseline, but the margin is tiny and not enough to justify remote promotion yet.
- Remote priority: low

## Remote Training

- Status: TODO
- Date:
- Seed(s):
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

- Prepared and measured as a cheap spline-inspired local mixer experiment.
- Interesting for exploration, but not a current winner.

## Next step

- Only revisit if we want to explore graph-style hybrids further; this first result is basically neutral.
