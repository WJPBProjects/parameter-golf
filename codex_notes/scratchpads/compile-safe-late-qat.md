# Experiment Note

## Experiment

- Name: Compile-safe Late-QAT
- Status: HOLD
- Owner: worker-compile-safe-late-qat
- Branch: `codex/compile-safe-late-qat`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/compile-safe-late-qat`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/compile-safe-late-qat/train_gpt.py`
  - `experiments/compile-safe-late-qat/train_gpt_mlx.py`

## Hypothesis

- A tensor-backed late-QAT toggle survives `torch.compile` better than the historical Python-class-attribute pattern and can close some of the quantization gap when enabled late in training.

## Scope

- Files expected to change:
  - `experiments/compile-safe-late-qat/train_gpt.py`
  - `experiments/compile-safe-late-qat/README.md`
  - `codex_notes/scratchpads/compile-safe-late-qat.md`
- Local screen command(s):
  - `./.venv/bin/python -m py_compile experiments/compile-safe-late-qat/train_gpt.py experiments/compile-safe-late-qat/train_gpt_mlx.py`
- Remote run command(s):
  - `QAT_ENABLED=1 LATE_QAT_THRESHOLD=0.15 RUN_ID=compile-safe-late-qat ./.venv/bin/python experiments/compile-safe-late-qat/train_gpt.py`

## Progress

- Added an experiment-local `CastedLinear` QAT gate backed by a tensor buffer rather than a Python class attribute.
- Added a late-enable hook in the training loop that flips QAT on once the LR scale falls below `LATE_QAT_THRESHOLD`.
- Kept the MLX copy unchanged because the actual experiment is CUDA / `torch.compile` focused.

## Local Screening

- Status: SKIPPED
- Date: 2026-03-27
- Seed(s): `1337`
- Log path:
- Artifact path(s):
- Throughput / wallclock:
- Val / BPB:
- Notes:
  - Syntax-only validation passed with `./.venv/bin/python -m py_compile experiments/compile-safe-late-qat/train_gpt.py experiments/compile-safe-late-qat/train_gpt_mlx.py`.
  - This branch does not have a meaningful Mac training screen; the real test is the CUDA PyTorch run.

## Promotion Decision

- Promote to remote: HOLD
- Reason:
  - Code is wired and syntax-valid, but there is no measured training/eval result yet.
  - This is a compile-safety experiment, so the actual signal is on the remote PyTorch path.
- Remote priority: medium

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

- The local portion of this branch is done.
- The branch now contains a compile-safe late-QAT implementation path, but it still needs a real CUDA run to determine whether the change actually helps.

## Next step

- Run the remote CUDA trainer with `QAT_ENABLED=1` and `LATE_QAT_THRESHOLD=0.15`, then compare the post-quant result against the current local/remote baseline once the run exists.
