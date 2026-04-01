# Active Run Status

Last updated: 2026-04-02 00:50 BST

## Current local execution

- Active wave: `latest-pr-tail`
- Profile: `confirm`
- Run tag: `latest_pr_tail_20260402`
- Session: `86084`
- Current experiment: `pr824_mimic`

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

## Automatic follow-on

- Current active wave:
  - `latest_pr_tail_20260402`
  - runs:
    - `pr824_mimic`
    - `qkgain5_pr1217`
    - `parallel_residuals_pr1204`
- Waiting session: `70197`
  - runs partial `PR1218` port after `latest_pr_tail_20260402_summary.txt` appears
  - run id:
    - `wd085_mlp4_pr1218_confirm_20260402`
- Waiting session: `82535`
  - runs `pr824_exploit_20260402` after the partial `PR1218` run finishes

## Parallel research lane

- Research sub-agents can run in parallel with the local MLX queue because they do not need the Apple GPU.
- Current themes in flight:
  - recent literature on compact / efficient LM ideas
  - latest public PR frontier mining

## Key reference benchmark

- Confirm-tier baseline on this laptop:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69279590`
  - log: `/Users/wulfie/code/parameter-golf/logs/rerun_wave_20260401_baseline.txt`
