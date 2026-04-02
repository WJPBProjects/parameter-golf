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
| QK_GAIN=5.0 (PR1217-inspired) | FAIL | HOLD | TODO | `codex/qkgain5-pr1217` | `/Users/wulfie/code/parameter-golf-worktrees/qkgain5-pr1217` | `codex_notes/scratchpads/qkgain5-pr1217.md` | Standalone `QK_GAIN_INIT=5.0` was a clear local miss on `latest_pr_tail_20260402` (`1.7045` vs baseline `1.6978`), so this is not attractive by itself. |
| Parallel Residuals (PR1204-inspired) | PASS | HOLD | TODO | `codex/parallel-residuals-pr1204` | `/Users/wulfie/code/parameter-golf-worktrees/parallel-residuals-pr1204` | `codex_notes/scratchpads/parallel-residuals-pr1204.md` | Partial port produced a real local win (`1.6785` vs baseline `1.6978`), but it is still weaker than `PR824 mimic`, so this is a secondary branch to stack or ablate rather than the main positive control. |
| MLP 4x partial PR1218 mimic | FAIL | HOLD | TODO | `codex/wd085-mlp4-pr1218` | `/Users/wulfie/code/parameter-golf-worktrees/wd085-mlp4-pr1218` | `codex_notes/scratchpads/wd085-mlp4-pr1218.md` | Post-quant quality was basically baseline (`1.6934`), but training was much slower (`390ms/step`) and the artifact blew the 16MB cap (`22.2MB`), so this partial `MLP_MULT=4` mimic is a local reject as implemented. |
| PR824 value-residual-only | PASS | HOLD | TODO | `codex/pr824-value-residual-only` | `/Users/wulfie/code/parameter-golf-worktrees/pr824-value-residual-only` | `codex_notes/scratchpads/pr824-value-residual-only.md` | Confirm result `1.67099164` versus fresh baseline `1.69601453`; this retains nearly all of full PR824 mimic’s gain, so value residual is now the confirmed main mechanism. |
| PR824 attn-gate-only | PASS | HOLD | TODO | `codex/pr824-attn-gate-only` | `/Users/wulfie/code/parameter-golf-worktrees/pr824-attn-gate-only` | `codex_notes/scratchpads/pr824-attn-gate-only.md` | Confirm result `1.68098646` beats fresh baseline `1.69601453`, so attention gating helps, but it is clearly weaker than value residual only. |
| PR824 + QK_GAIN=5.0 | TODO | HOLD | TODO | `codex/pr824-qkgain5` | `/Users/wulfie/code/parameter-golf-worktrees/pr824-qkgain5` | `codex_notes/scratchpads/pr824-qkgain5.md` | Branch repaired: trainer now uses the PR824 mimic stack with `QK_GAIN_INIT=5.0` as the only intended delta, and passed `py_compile`; needs rerun. |
| PR824 with XSA last 4 | TODO | HOLD | TODO | `codex/pr824-xsa4` | `/Users/wulfie/code/parameter-golf-worktrees/pr824-xsa4` | `codex_notes/scratchpads/pr824-xsa4.md` | Branch repaired: trainer default is now `XSA_LAST_N=4` while preserving PR824 mimic value/gate wiring, and passed `py_compile`; needs rerun. |
| Hyperconnection-lite | FAIL | HOLD | TODO | `codex/hyperconnection-lite` | `/Users/wulfie/code/parameter-golf-worktrees/hyperconnection-lite` | `codex_notes/scratchpads/hyperconnection-lite.md` | Confirm result `1.70267420` is a clear regression versus fresh baseline `1.69239991`; drop this topology/init for now. |
| KGIIR-lite | PASS | HOLD | TODO | `codex/kgiir-lite` | `/Users/wulfie/code/parameter-golf-worktrees/kgiir-lite` | `codex_notes/scratchpads/kgiir-lite.md` | Confirm result `1.67562160` beats fresh baseline `1.69239991` by `-0.01677831` with a `+5.1%` step-time cost, so this is the strongest new explore win and deserves one PR824/value-residual stack test. |
| PR824 + KGIIR-lite | TODO | HOLD | TODO | `codex/pr824-kgiir-lite` | `/Users/wulfie/code/parameter-golf-worktrees/pr824-kgiir-lite` | `codex_notes/scratchpads/pr824-kgiir-lite.md` | Prepared stack test combining PR824's value/gate/XSA6 path with the fixed 4-tap KGIIR-lite temporal mixer; `py_compile` passed. |
| Attention Residuals-lite | PASS | HOLD | TODO | `codex/attnres-lite` | `/Users/wulfie/code/parameter-golf-worktrees/attnres-lite` | `codex_notes/scratchpads/attnres-lite.md` | Confirm result `1.68501439` beats fresh baseline `1.69239991` with a small `+3.9%` step-time cost, so this is a modest but real explore win worth one PR824/value-residual stack attempt. |
| PR824 + AttnRes-lite | TODO | HOLD | TODO | `codex/pr824-attnres-lite` | `/Users/wulfie/code/parameter-golf-worktrees/pr824-attnres-lite` | `codex_notes/scratchpads/pr824-attnres-lite.md` | Prepared stack test combining PR824's value/gate/XSA6 path with the AttnRes-lite late decoder skip gate; `py_compile` passed. |
| PR824 + value-embedding-lite | TODO | HOLD | TODO | `codex/pr824-value-embedding-lite` | `/Users/wulfie/code/parameter-golf-worktrees/pr824-value-embedding-lite` | `codex_notes/scratchpads/pr824-value-embedding-lite.md` | Prepared as a PR1215/PR1216-inspired exploit stack. Adds a tiny learned token-value embedding reinjection path on top of the PR824 mimic core; syntax-checked only so far. |
| PR824 + ParallelResiduals | TODO | HOLD | TODO | `codex/pr824-parallel-residuals` | `/Users/wulfie/code/parameter-golf-worktrees/pr824-parallel-residuals` | `codex_notes/scratchpads/pr824-parallel-residuals.md` | Prepared exploit stack combining the PR824 mimic core with a minimal two-stream ParallelResiduals path in later layers; syntax-checked only so far. |
| MoHD last-MLP lite | TODO | HOLD | TODO | `codex/mohd-lastmlp-lite` | `/Users/wulfie/code/parameter-golf-worktrees/mohd-lastmlp-lite` | `codex_notes/scratchpads/mohd-lastmlp-lite.md` | Branch-local gated tail-channel MLP path added to the last decoder blocks; syntax-checked only so far. |
