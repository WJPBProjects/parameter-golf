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
- restarted tail-wave positive control completed:
  - `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid/logs/latest_pr_tail_20260402_pr824_mimic.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.66856748`
  - this closely matches the earlier `1.67002607` result, which is strong evidence that the local confirm harness is directionally trustworthy
- `qkgain5_pr1217` completed:
  - `/Users/wulfie/code/parameter-golf-worktrees/qkgain5-pr1217/logs/latest_pr_tail_20260402_qkgain5_pr1217.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.70448780`
  - local miss versus the latest-PR baseline `1.69780921`
- `parallel_residuals_pr1204` completed:
  - `/Users/wulfie/code/parameter-golf-worktrees/parallel-residuals-pr1204/logs/latest_pr_tail_20260402_parallel_residuals_pr1204.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.67852834`
  - local win versus baseline, but still clearly weaker than `PR824 mimic`
- `wd085_mlp4_pr1218_confirm_20260402` completed:
  - `/Users/wulfie/code/parameter-golf-worktrees/wd085-mlp4-pr1218/logs/wd085_mlp4_pr1218_confirm_20260402.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69335416`
  - `step_avg: 390.16ms`
  - `serialized_model_int8_zlib: 22204302 bytes`
  - local quality is basically flat versus baseline, but the branch is much slower and the artifact is far above the 16MB cap, so this partial `MLP_MULT=4` port is not a viable direction in its current form
- currently active:
  - `pr824_exploit_20260402`
- queued after `pr824_exploit_20260402_summary.txt` appears:
  - `explore_lite_20260402`

## Active `pr824-exploit` wave

Fresh wave baseline:

- `/Users/wulfie/code/parameter-golf/logs/pr824_exploit_20260402_baseline.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.69601453`
- `step_avg: 323.76ms`
- `serialized_model_int8_zlib: 15128342 bytes`

Positive control:

- `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid/logs/pr824_exploit_20260402_pr824_mimic.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.66814857`
- `delta vs fresh baseline: -0.02786596`
- `step_avg: 310.41ms`
- `serialized_model_int8_zlib: 15336317 bytes`

Value-residual-only ablation:

- `/Users/wulfie/code/parameter-golf-worktrees/pr824-value-residual-only/logs/pr824_exploit_20260402_pr824_value_residual_only.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.67099164`
- `delta vs fresh baseline: -0.02502289`
- `delta vs full PR824 mimic: +0.00284307`
- `step_avg: 324.12ms`
- `serialized_model_int8_zlib: 15395185 bytes`

Interpretation:

- this baseline is `+0.00321863` worse than the earlier `rerun_wave_20260401` confirm baseline
- that amount of drift is small enough that the wave is still usable, but borderline deltas in the `0.003` range should be treated carefully
- the PR824 positive control still wins by a wide margin and is slightly faster than the fresh baseline in this run, so this wave is healthy enough to trust the value-residual and attn-gate ablations
- `value_residual_only` keeps almost all of the full PR824 gain, so the value path is very likely the dominant mechanism and attention gating should be treated as an incremental add-on unless the next ablation contradicts that
