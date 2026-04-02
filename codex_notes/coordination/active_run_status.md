# Active Run Status

Last updated: 2026-04-02 12:51 BST

## Current local execution

- Active wave: `explore-lite`
- Profile: `confirm`
- Run id: `explore_lite_20260402`
- Current session: `20353`
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
  - `pr824_qkgain5` exited `143` after manual stop because the branch trainer is only standalone `QK_GAIN=5.0`, not PR824 + QK gain
  - `pr824_xsa4` exited `143` after manual stop because the branch trainer still logs `xsa_last_n:6`, not `4`
  - both branches need code/config repair before rerunning

## Automatic follow-on

- `latest_pr_tail_20260402` is complete and summarized in:
  - `/Users/wulfie/code/parameter-golf/logs/latest_pr_tail_20260402_summary.txt`
- Waiting session: `1044`
  - runs `next_frontier_lite_20260402` after `explore_lite_20260402_summary.txt` appears

## Parallel research lane

- Research sub-agents can run in parallel with the local MLX queue because they do not need the Apple GPU.
- Current themes in flight:
  - recent literature on compact / efficient LM ideas
  - latest public PR frontier mining

## Key reference benchmark

- Confirm-tier baseline on this laptop:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69279590`
  - log: `/Users/wulfie/code/parameter-golf/logs/rerun_wave_20260401_baseline.txt`
