# Results Snapshot (2026-04-02)

## Completed confirm-tier rerun wave

Reference baseline:

- `/Users/wulfie/code/parameter-golf/logs/rerun_wave_20260401_baseline.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.69279590`

Completed experiments:

| Experiment | Post-quant val_bpb | Delta vs baseline | Step avg | Artifact bytes | Log |
|---|---:|---:|---:|---:|---|
| `PR824 mimic` | `1.67002607` | `-0.02276983` | `317.79ms` | `15329488` | `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid/logs/rerun_tail_20260401_pr824_mimic.txt` |
| `xsa_all` | `1.68548359` | `-0.00731231` | `460.37ms` | `15191513` | `/Users/wulfie/code/parameter-golf-worktrees/xsa-all/logs/rerun_tail_20260401_xsa_all.txt` |
| `leakyrelu` | `1.69254747` | `-0.00024843` | `295.98ms` | `15137161` | `/Users/wulfie/code/parameter-golf-worktrees/leakyrelu-slope-sweep/logs/rerun_tail_20260401_leakyrelu.txt` |
| `gptq_calib_validation` | `1.69487012` | `+0.00207422` | `286.68ms` | `15131058` | `/Users/wulfie/code/parameter-golf-worktrees/gptq-self-calibration/logs/rerun_tail_20260401_gptq_calib_validation.txt` |
| `gptq_calib_random_tokens` | `1.69577447` | `+0.00297857` | `280.91ms` | `15126375` | `/Users/wulfie/code/parameter-golf-worktrees/gptq-self-calibration/logs/rerun_tail_20260401_gptq_calib_random_tokens.txt` |
| `selective_post_gptq_pruning` | `1.70052767` | `+0.00773177` | `280.76ms` | `14957863` | `/Users/wulfie/code/parameter-golf-worktrees/selective-post-gptq-pruning/logs/rerun_tail_20260401_selective_post_gptq_pruning.txt` |
| `splineconv_hybrid` | `1.70429006` | `+0.01149416` | `278.86ms` | `15177587` | `/Users/wulfie/code/parameter-golf-worktrees/splineconv-hybrid/logs/rerun_tail_20260401_splineconv_hybrid.txt` |
| `gptq_calib_self_generated` | `1.71421559` | `+0.02141969` | `266.49ms` | `15137637` | `/Users/wulfie/code/parameter-golf-worktrees/gptq-self-calibration/logs/rerun_tail_20260401_gptq_calib_self_generated.txt` |
| `rope_lnscale` | `1.71609602` | `+0.02330012` | `277.68ms` | `14955040` | `/Users/wulfie/code/parameter-golf-worktrees/rope-lnscale-grid/logs/rerun_tail_20260401_rope_lnscale.txt` |

## Main conclusions

- The local confirm harness is giving real signal.
- `PR824 mimic` is the clearest winner so far.
- `xsa_all` still helps, but only modestly and with a bad speed penalty.
- Most other tested ideas are neutral or worse.

## In progress

Latest-PR signal wave:

- baseline completed:
  - `/Users/wulfie/code/parameter-golf/logs/latest_pr_signal_20260401_baseline.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69780921`
- `pr824_mimic` rerun is currently active
- queued after that:
  - `qkgain5_pr1217`
  - `parallel_residuals_pr1204`
- queued after the latest-PR summary appears:
  - partial `PR1218` mimic with `MLP_MULT=4`
