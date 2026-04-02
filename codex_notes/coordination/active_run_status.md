# Active Run Status

Last updated: 2026-04-02 15:38 BST

## Current local execution

- Active wave: `next-frontier-lite`
- Profile: `confirm`
- Run id: `next_frontier_lite_20260402`
- Current session: `1044`
- Current experiment: `mohd_lastmlp_lite`

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

## Automatic follow-on

- `latest_pr_tail_20260402` is complete and summarized in:
  - `/Users/wulfie/code/parameter-golf/logs/latest_pr_tail_20260402_summary.txt`
- Waiting session: `1044`
  - runs `next_frontier_lite_20260402` after `explore_lite_20260402_summary.txt` appears
- Waiting session: `14285`
  - runs `pr824_fixups_20260402` after `next_frontier_lite_20260402_summary.txt` appears
- Waiting session: `34638`
  - runs `pr824_stacks_20260402` after `pr824_fixups_20260402_summary.txt` appears
- Waiting session: `60192`
  - runs `pr824_explore2_20260402` after `pr824_stacks_20260402_summary.txt` appears
- Waiting session: `45526`
  - runs `value_embedding_retry_20260402` after `pr824_explore2_20260402_summary.txt` appears

## Parallel research lane

- Research sub-agents can run in parallel with the local MLX queue because they do not need the Apple GPU.
- Current themes in flight:
  - recent literature on compact / efficient LM ideas
  - latest public PR frontier mining

## Key reference benchmark

- Confirm-tier baseline on this laptop:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69279590`
  - log: `/Users/wulfie/code/parameter-golf/logs/rerun_wave_20260401_baseline.txt`
