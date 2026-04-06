# Experiment

- Name: Smear Shortcut Lite
- Status: IN_PROGRESS
- Owner: main-agent
- Branch: `codex/smear-shortcut-lite`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/smear-shortcut-lite`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/smear-shortcut-lite/train_gpt.py`
  - `experiments/smear-shortcut-lite/train_gpt_mlx.py`

## Hypothesis

- A tiny late-layer previous-token shortcut may recover some cheap local syntax signal without the size or runtime cost of a full embedding-path branch.

## Scope

- Files expected to change:
  - `experiments/smear-shortcut-lite/train_gpt.py`
  - `experiments/smear-shortcut-lite/train_gpt_mlx.py`
- Local screen command(s):
  - `SMEAR_ENABLED=1 SMEAR_LAST_N=3 SMEAR_INIT=0.0 TRAIN_MLX_SCRIPT=experiments/smear-shortcut-lite/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh`
- Remote run command(s):
  - not promoted yet

## Progress

- Created experiment-local trainer copies from the baseline trainers.
- Added a tiny per-dimension `SmearGate` that blends each token latent with the previous token latent.
- Wired the gate only into the last `SMEAR_LAST_N` blocks so the effect stays late-layer-focused.
- Added optimizer and quantization bookkeeping so `smear` parameters are treated as scalar control tensors.

## Local Screening

- Status: TODO
- Date:
- Seed(s):
- Log path:
- Artifact path(s):
- Throughput / wallclock:
- Val / BPB:
- Notes:

## Promotion Decision

- Promote to remote: HOLD
- Reason:
  - local preflight still needs to prove the copied trainers compile and run
- Remote priority:
  - none yet

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

- Cheap original architecture branch, intentionally kept narrow enough to screen locally before any remote spend.

## Next step

- Run `py_compile`, tiny CPU instantiate/forward, and one MLX smoke if the path is practical.
