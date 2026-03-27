# Experiment Board

Use this file to coordinate active and planned experiments across agents.

Also read:

- `codex_notes/coordination/baseline_benchmarks.md`
- `codex_notes/coordination/promotion_rubric.md`

## Status conventions

- `TODO`
- `IN_PROGRESS:<agent_id>`
- `DONE`
- `BLOCKED`
- `PASS`
- `FAIL`
- `HOLD`
- `READY`
- `SKIPPED`

When claiming an experiment:

1. Change the relevant local or remote status to `IN_PROGRESS:<agent_id>`.
2. Fill in or update the branch, worktree, and note file.
3. Keep the note file current while you work.
4. Reread this file immediately before each edit so you do not clobber another agent's changes.

When finishing:

1. Update the local-screen status.
2. Update the promotion decision.
3. Update the remote-run status if applicable.
4. Update the summary with the best current conclusion.
5. If the promotion decision changed, explain why in the experiment note.

## Column meaning

- `Local screen`: status of the local smoke/screening run
- `Promote remote`: whether the current local result should be rerun on remote compute
- `Remote run`: status of the remote training/evaluation follow-up
- `Summary`: the shortest current answer to “is this working?”

## Active / planned experiments

| Experiment | Local screen | Promote remote | Remote run | Branch | Worktree | Note file | Summary |
|---|---|---|---|---|---|---|---|
| XSA all layers | PASS | READY | TODO | `codex/xsa-all` | `/Users/wulfie/code/parameter-golf-worktrees/xsa-all` | `codex_notes/scratchpads/xsa-all.md` | Local screen improved post-quant `val_bpb` to `3.7024` with artifact `7,839,700` bytes; ready for remote confirmation. |
| PR824 mimic: XSA6 + GatedAttn + ValueResid | PASS | READY | TODO | `codex/pr824-mimic-gatedattn-valueresid` | `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid` | `codex_notes/scratchpads/pr824-mimic-gatedattn-valueresid.md` | On the local-screen harness, this partial mimic improved `val_bpb` from `2.2674` to `2.2407` with a modest speed and size cost; good directional signal. |
| GPTQ self calibration | READY | HOLD | TODO | `codex/gptq-self-calibration` | `/Users/wulfie/code/parameter-golf-worktrees/gptq-self-calibration` | `codex_notes/scratchpads/gptq-self-calibration.md` | Prep is complete for sequential calibration-source runs; MLX trainer now supports `validation`, `self_generated`, and `random_tokens`, and the self-generated sanity probe passed. |
| Selective post-GPTQ pruning | READY | HOLD | TODO | `codex/selective-post-gptq-pruning` | `/Users/wulfie/code/parameter-golf-worktrees/selective-post-gptq-pruning` | `codex_notes/scratchpads/selective-post-gptq-pruning.md` | Experiment-local pruning knobs are prepared and syntax-checked; ready for the first sequential local screen. |
| Compile-safe Late-QAT | SKIPPED | HOLD | TODO | `codex/compile-safe-late-qat` | `/Users/wulfie/code/parameter-golf-worktrees/compile-safe-late-qat` | `codex_notes/scratchpads/compile-safe-late-qat.md` | Compile-safe QAT path is prepared and syntax-checked, but meaningful evaluation belongs on the remote CUDA path rather than a local MLX run. |
| LeakyReLU slope sweep | PASS | HOLD | TODO | `codex/leakyrelu-slope-sweep` | `/Users/wulfie/code/parameter-golf-worktrees/leakyrelu-slope-sweep` | `codex_notes/scratchpads/leakyrelu-slope-sweep.md` | Sweep plumbing works and smoke runs are clean, but current evidence is functional only, not yet enough for remote promotion. |
| RoPE + LN-scale grid | READY | HOLD | TODO | `codex/rope-lnscale-grid` | `/Users/wulfie/code/parameter-golf-worktrees/rope-lnscale-grid` | `codex_notes/scratchpads/rope-lnscale-grid.md` | Experiment-local RoPE and scale knobs are prepared and syntax-checked; ready for sequential local screening. |
| SplineConv hybrid | READY | HOLD | TODO | `codex/splineconv-hybrid` | `/Users/wulfie/code/parameter-golf-worktrees/splineconv-hybrid` | `codex_notes/scratchpads/splineconv-hybrid.md` | Experiment-local spline-inspired mixer is prepared and syntax-checked; waiting for the later sequential local screen. |
