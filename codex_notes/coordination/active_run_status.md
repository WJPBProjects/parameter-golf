# Active Run Status

Last updated: 2026-04-02 17:24 BST

## Current local execution

- Active wave: `pr824-stacks`
- Profile: `confirm`
- Run id: `pr824_stacks_20260402`
- Current session: `34638`
- Current experiment: `baseline`

## Completed reference waves

- `xsa_all`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.68548359`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/xsa-all/logs/rerun_tail_20260401_xsa_all.txt`
- `leakyrelu`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69254747`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/leakyrelu-slope-sweep/logs/rerun_tail_20260401_leakyrelu.txt`
- `pr824_mimic`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.67002607`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid/logs/rerun_tail_20260401_pr824_mimic.txt`
- `gptq_calib_validation`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69487012`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/gptq-self-calibration/logs/rerun_tail_20260401_gptq_calib_validation.txt`
- `latest_pr_tail` positive control:
  - `pr824_mimic`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.66856748`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid/logs/latest_pr_tail_20260402_pr824_mimic.txt`
- `latest_pr_tail` standalone QK-gain probe:
  - `qkgain5_pr1217`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.70448780`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/qkgain5-pr1217/logs/latest_pr_tail_20260402_qkgain5_pr1217.txt`
- `latest_pr_tail` partial parallel residuals probe:
  - `parallel_residuals_pr1204`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.67852834`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/parallel-residuals-pr1204/logs/latest_pr_tail_20260402_parallel_residuals_pr1204.txt`
- standalone partial `PR1218`:
  - `wd085_mlp4_pr1218_confirm_20260402`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69335416`
  - `step_avg: 390.16ms`
  - `serialized_model_int8_zlib: 22204302 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/wd085-mlp4-pr1218/logs/wd085_mlp4_pr1218_confirm_20260402.txt`
  - current interpretation: local quality is flat, speed is worse, and the artifact exceeds the 16MB cap, so this branch is a reject unless a much smaller `MLP_MULT` / compression variant is tried
- `pr824_exploit_20260402` baseline:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69601453`
  - `step_avg: 323.76ms`
  - `serialized_model_int8_zlib: 15128342 bytes`
  - log: `/Users/wulfie/code/parameter-golf/logs/pr824_exploit_20260402_baseline.txt`
- `pr824_exploit_20260402` positive control:
  - `pr824_mimic`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.66814857`
  - `step_avg: 310.41ms`
  - `serialized_model_int8_zlib: 15336317 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid/logs/pr824_exploit_20260402_pr824_mimic.txt`
  - interpretation: the positive control still beats the fresh wave baseline by `-0.02786596`, so the ablation ranking in this wave is trustworthy
- `pr824_exploit_20260402` value-residual-only ablation:
  - `pr824_value_residual_only`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.67099164`
  - `step_avg: 324.12ms`
  - `serialized_model_int8_zlib: 15395185 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/pr824-value-residual-only/logs/pr824_exploit_20260402_pr824_value_residual_only.txt`
  - interpretation: retains almost all of the PR824-family gain by itself (`-0.02502289` vs baseline, only `+0.00284307` worse than full PR824 mimic), so the value-residual path is confirmed as the main mechanism
- `pr824_exploit_20260402` attn-gate-only ablation:
  - `pr824_attn_gate_only`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.68098646`
  - `step_avg: 322.27ms`
  - `serialized_model_int8_zlib: 15104730 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/pr824-attn-gate-only/logs/pr824_exploit_20260402_pr824_attn_gate_only.txt`
  - interpretation: attention gating alone is a real but smaller win (`-0.01502807` vs baseline), clearly weaker than value residual only and full PR824 mimic
- `pr824_exploit_20260402` invalid fixup cases:
  - `pr824_qkgain5` exited `143` after manual stop because the branch trainer was only standalone `QK_GAIN=5.0`, not PR824 + QK gain
  - `pr824_xsa4` exited `143` after manual stop because the branch trainer still logged `xsa_last_n:6`, not `4`
  - both branches have now been repaired by dedicated workers and are queued for a fresh `pr824-fixups` wave
- `explore_lite_20260402` baseline:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69239991`
  - `step_avg: 303.23ms`
  - `serialized_model_int8_zlib: 15128268 bytes`
  - log: `/Users/wulfie/code/parameter-golf/logs/explore_lite_20260402_baseline.txt`
- `explore_lite_20260402` attnres-lite:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.68501439`
  - `step_avg: 315.04ms`
  - `serialized_model_int8_zlib: 15311780 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/attnres-lite/logs/explore_lite_20260402_attnres_lite.txt`
  - interpretation: a real but modest win (`-0.00738552` vs fresh baseline) at about `+3.9%` step-time cost, so this is a secondary positive explore direction
- `explore_lite_20260402` hyperconnection-lite:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.70267420`
  - `step_avg: 301.77ms`
  - `serialized_model_int8_zlib: 15129316 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/hyperconnection-lite/logs/explore_lite_20260402_hyperconnection_lite.txt`
  - interpretation: clear local regression versus fresh baseline (`+0.01027429`), so this branch is a drop unless a materially different initialization/topology is tried later
- `explore_lite_20260402` kgiir-lite:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.67562160`
  - `step_avg: 318.83ms`
  - `serialized_model_int8_zlib: 15173162 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/kgiir-lite/logs/explore_lite_20260402_kgiir_lite.txt`
  - interpretation: stronger local win than `attnres_lite` (`-0.01677831` vs fresh baseline), so this branch deserves one `PR824/value-residual + KGIIR-lite` stack test
- `next_frontier_lite_20260402` baseline:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69574046`
  - `step_avg: 325.78ms`
  - `serialized_model_int8_zlib: 15143021 bytes`
  - log: `/Users/wulfie/code/parameter-golf/logs/next_frontier_lite_20260402_baseline.txt`
- `next_frontier_lite_20260402` value-embedding first attempt:
  - pre-quant `step:4000/4000 val_bpb: 1.6884`
  - run exited `1` at `mx.savez(...flat_state)` with `RuntimeError: std::bad_cast`
  - stderr: `/Users/wulfie/code/parameter-golf/logs/next_frontier_lite_20260402_pr824_value_embedding_lite.stderr.txt`
  - root cause: non-array Python metadata leaves in `model.state`; branch-local fix is prepared and this experiment needs a clean rerun
- `next_frontier_lite_20260402` PR824 + ParallelResiduals:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.67725281`
  - `step_avg: 328.92ms`
  - `serialized_model_int8_zlib: 15300798 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/pr824-parallel-residuals/logs/next_frontier_lite_20260402_pr824_parallel_residuals.txt`
  - interpretation: real local win versus this wave's baseline (`-0.01848765`), but still weaker than plain `PR824 mimic`, so this is not yet evidence of positive composition
- `next_frontier_lite_20260402` MoHD last-MLP lite:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69694169`
  - `step_avg: 312.02ms`
  - `serialized_model_int8_zlib: 15080319 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/mohd-lastmlp-lite/logs/next_frontier_lite_20260402_mohd_lastmlp_lite.txt`
  - interpretation: effectively flat to slightly worse than the fresh baseline (`+0.00120123`), so this MoHD-style tail-gate is a local miss in this form
- `pr824_fixups_20260402` baseline:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69615068`
  - `step_avg: 310.25ms`
  - `serialized_model_int8_zlib: 15136050 bytes`
  - log: `/Users/wulfie/code/parameter-golf/logs/pr824_fixups_20260402_baseline.txt`
- `pr824_fixups_20260402` PR824 mimic positive control:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.66833719`
  - `step_avg: 336.05ms`
  - `serialized_model_int8_zlib: 15336584 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid/logs/pr824_fixups_20260402_pr824_mimic.txt`
  - interpretation: fresh positive control still improves by `-0.02781349` versus this wave's baseline, so the repaired `qkgain5` and `xsa4` comparisons are meaningful
- `pr824_fixups_20260402` PR824 + QK_GAIN=5.0:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.66190993`
  - `step_avg: 333.05ms`
  - `serialized_model_int8_zlib: 15403892 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/pr824-qkgain5/logs/pr824_fixups_20260402_pr824_qkgain5.txt`
  - interpretation: new best local result so far (`-0.00642726` vs fresh PR824 mimic and `-0.03424075` vs baseline), so this branch should be treated as the current exploit target
- `pr824_fixups_20260402` PR824 with XSA last 4:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.66929723`
  - `step_avg: 327.47ms`
  - `serialized_model_int8_zlib: 15330969 bytes`
  - log: `/Users/wulfie/code/parameter-golf-worktrees/pr824-xsa4/logs/pr824_fixups_20260402_pr824_xsa4.txt`
  - interpretation: beats the fresh fixup baseline, but is slightly worse than PR824 mimic and clearly behind `pr824-qkgain5`, so keep this as an ablation result rather than a new exploit branch

## Automatic follow-on

- `latest_pr_tail_20260402` is complete and summarized in:
  - `/Users/wulfie/code/parameter-golf/logs/latest_pr_tail_20260402_summary.txt`
- Waiting session: `1044`
  - completed `next_frontier_lite_20260402`; summary at `/Users/wulfie/code/parameter-golf/logs/next_frontier_lite_20260402_summary.txt`
- Waiting session: `34638`
  - currently running `pr824_stacks_20260402`
- Waiting session: `60192`
  - runs `pr824_explore2_20260402` after `pr824_stacks_20260402_summary.txt` appears
- Waiting session: `45526`
  - runs `value_embedding_retry_20260402` after `pr824_explore2_20260402_summary.txt` appears
- Waiting session: `84238`
  - runs `qkgain_neighborhood_20260402` after `value_embedding_retry_20260402_summary.txt` appears
- Waiting session: `36684`
  - runs `next_exploit_frontier_20260402` after `qkgain_neighborhood_20260402_summary.txt` appears

## Parallel research lane

- Research sub-agents can run in parallel with the local MLX queue because they do not need the Apple GPU.
- Latest sidecars completed and were consolidated into:
  - `codex_notes/planning/value_path_frontier_memo_20260402.md`
- Current recommendation from that memo:
  - keep exploiting the PR824 value/gate/QK/KGIIR family locally
  - prepare `Softpick-lite`, token-wise residual-gate, and tiny-memory-slot branches only if the current queued waves stall

## Key reference benchmark

- Confirm-tier baseline on this laptop:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69279590`
  - log: `/Users/wulfie/code/parameter-golf/logs/rerun_wave_20260401_baseline.txt`
