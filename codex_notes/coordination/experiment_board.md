# Experiment Board

Use this file to coordinate active and planned experiments across agents.

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

## Column meaning

- `Local screen`: status of the local smoke/screening run
- `Promote remote`: whether the current local result should be rerun on remote compute
- `Remote run`: status of the remote training/evaluation follow-up
- `Summary`: the shortest current answer to “is this working?”

## Active / planned experiments

| Experiment | Local screen | Promote remote | Remote run | Branch | Worktree | Note file | Summary |
|---|---|---|---|---|---|---|---|
| XSA all layers | TODO | HOLD | TODO | `codex/xsa-all` | | `codex_notes/scratchpads/xsa-all.md` | Promote XSA from late layers to all layers and measure BPB / speed tradeoff. |
| GPTQ self calibration | TODO | HOLD | TODO | `codex/gptq-self-calibration` | | `codex_notes/scratchpads/gptq-self-calibration.md` | Compare validation-style, self-generated, and random-token calibration sources. |
| Selective post-GPTQ pruning | TODO | HOLD | TODO | `codex/selective-post-gptq-pruning` | | `codex_notes/scratchpads/selective-post-gptq-pruning.md` | Trim low-damage quantized weights to hit artifact targets more gracefully. |
| Compile-safe Late-QAT | TODO | HOLD | TODO | `codex/compile-safe-late-qat` | | `codex_notes/scratchpads/compile-safe-late-qat.md` | Make QAT toggles survive `torch.compile` and verify quantization-gap improvements. |
| LeakyReLU slope sweep | TODO | HOLD | TODO | `codex/leakyrelu-slope-sweep` | | `codex_notes/scratchpads/leakyrelu-slope-sweep.md` | Sweep LeakyReLU² slopes on a strong stack. |
| RoPE + LN-scale grid | TODO | HOLD | TODO | `codex/rope-lnscale-grid` | | `codex_notes/scratchpads/rope-lnscale-grid.md` | Sweep partial RoPE dimensions and layer-scale schedules. |
| SplineConv hybrid | TODO | HOLD | TODO | `codex/splineconv-hybrid` | | `codex_notes/scratchpads/splineconv-hybrid.md` | Exploratory low-priority graph hybrid with a small spline-conv local branch. |
