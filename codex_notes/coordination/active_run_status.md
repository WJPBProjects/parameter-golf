# Active Run Status

Last updated: 2026-04-01 22:13 BST

## Current local execution

- Active wave: `rerun-tail`
- Profile: `confirm`
- Run tag: `rerun_tail_20260401`
- Session: `60781`
- Top-level PID: `79715`
- Current experiment: `gptq_calib_self_generated`

## Completed in this resumed pass

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

## Still queued inside `rerun-tail`

- `gptq_calib_self_generated`
- `gptq_calib_random_tokens`
- `selective_post_gptq_pruning`
- `rope_lnscale`
- `splineconv_hybrid`

## Automatic follow-on

- A second waiting session will launch the latest public-PR signal wave after `rerun-tail` exits.
- Waiting session: `49354`
- Follow-on run tag: `latest_pr_signal_20260401`
- That follow-on wave will run:
  - `baseline`
  - `pr824_mimic`
  - `qkgain5_pr1217`
  - `parallel_residuals_pr1204`
- A third waiting session will launch one extra cheap April 1 frontier mutation after the latest-PR summary file is written.
- Waiting session: `95081`
- Extra follow-on run:
  - `wd085_mlp4_pr1218_confirm`
  - partial `PR1218` mimic with `MLP_MULT=4` only

## Parallel research lane

- Research sub-agents can run in parallel with the local MLX queue because they do not need the Apple GPU.
- Current themes in flight:
  - recent literature on compact / efficient LM ideas
  - latest public PR frontier mining

## Key reference benchmark

- Confirm-tier baseline on this laptop:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69279590`
  - log: `/Users/wulfie/code/parameter-golf/logs/rerun_wave_20260401_baseline.txt`
