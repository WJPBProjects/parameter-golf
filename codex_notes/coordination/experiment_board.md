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
| XSA all layers | PASS | HOLD | TODO | `codex/xsa-all` | `/Users/wulfie/code/parameter-golf-worktrees/xsa-all` | `codex_notes/scratchpads/xsa-all.md` | Confirm-tier rerun on the new laptop improved modestly from `1.6928` baseline to `1.6855`, but with a major late-training slowdown; still plausible, but not yet a clean standout. |
| PR824 mimic: XSA6 + GatedAttn + ValueResid | PASS | READY | TODO | `codex/pr824-mimic-gatedattn-valueresid` | `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid` | `codex_notes/scratchpads/pr824-mimic-gatedattn-valueresid.md` | Confirm-tier rerun on the new laptop improved strongly from `1.6928` baseline to `1.6700` post-quant BPB, so it remains the clearest local winner and the best current positive control. |
| GPTQ self calibration | FAIL | HOLD | TODO | `codex/gptq-self-calibration` | `/Users/wulfie/code/parameter-golf-worktrees/gptq-self-calibration` | `codex_notes/scratchpads/gptq-self-calibration.md` | On the stronger local-screen harness, all three calibration sources regressed after the final quantized eval; this family is not working locally right now. |
| Selective post-GPTQ pruning | FAIL | HOLD | TODO | `codex/selective-post-gptq-pruning` | `/Users/wulfie/code/parameter-golf-worktrees/selective-post-gptq-pruning` | `codex_notes/scratchpads/selective-post-gptq-pruning.md` | At `POST_GPTQ_PRUNE_FRACTION=0.02`, it saves about `203KB` but regresses post-quant `val_bpb` from `2.1573` to `2.1604`; not a winner at this setting. |
| Compile-safe Late-QAT | SKIPPED | HOLD | TODO | `codex/compile-safe-late-qat` | `/Users/wulfie/code/parameter-golf-worktrees/compile-safe-late-qat` | `codex_notes/scratchpads/compile-safe-late-qat.md` | Compile-safe QAT path is prepared and syntax-checked, but meaningful evaluation belongs on the remote CUDA path rather than a local MLX run. |
| LeakyReLU slope sweep | FAIL | HOLD | TODO | `codex/leakyrelu-slope-sweep` | `/Users/wulfie/code/parameter-golf-worktrees/leakyrelu-slope-sweep` | `codex_notes/scratchpads/leakyrelu-slope-sweep.md` | Confirm-tier rerun on the new laptop stayed essentially flat to slightly worse than baseline (`1.6925` vs `1.6928`), so this remains low priority. |
| RoPE + LN-scale grid | FAIL | HOLD | TODO | `codex/rope-lnscale-grid` | `/Users/wulfie/code/parameter-golf-worktrees/rope-lnscale-grid` | `codex_notes/scratchpads/rope-lnscale-grid.md` | First screened point (`ROPE_DIM=16`, `LN_SCALE_INIT=inv_sqrt`) regressed badly on the stronger harness (`2.1797` vs `2.1573`); not promising so far. |
| SplineConv hybrid | HOLD | HOLD | TODO | `codex/splineconv-hybrid` | `/Users/wulfie/code/parameter-golf-worktrees/splineconv-hybrid` | `codex_notes/scratchpads/splineconv-hybrid.md` | On the stronger harness, the spline hybrid was essentially neutral (`2.1568` vs `2.1573` baseline) with a small size and speed cost; interesting but not promotable yet. |
| QK_GAIN=5.0 (PR1217-inspired) | TODO | HOLD | TODO | `codex/qkgain5-pr1217` | `/Users/wulfie/code/parameter-golf-worktrees/qkgain5-pr1217` | `codex_notes/scratchpads/qkgain5-pr1217.md` | Cheap latest-PR signal check: test whether the `QK_GAIN_INIT=5.0` improvement direction shows up locally too. |
| Parallel Residuals (PR1204-inspired) | IN_PROGRESS:main-agent | HOLD | TODO | `codex/parallel-residuals-pr1204` | `/Users/wulfie/code/parameter-golf-worktrees/parallel-residuals-pr1204` | `codex_notes/scratchpads/parallel-residuals-pr1204.md` | Local partial port in progress. This is the newest architecture-style positive control from the live frontier that looks meaningfully MLX-portable. |
| MLP 4x partial PR1218 mimic | TODO | HOLD | TODO | `codex/wd085-mlp4-pr1218` | `/Users/wulfie/code/parameter-golf-worktrees/wd085-mlp4-pr1218` | `codex_notes/scratchpads/wd085-mlp4-pr1218.md` | Prepared as a cheap next-step latest-PR signal check. This branch currently ports only the `MLP_MULT=4` part of PR1218, not the larger vocab or `WD=0.085`. |
