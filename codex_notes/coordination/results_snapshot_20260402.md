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

Attn-gate-only ablation:

- `/Users/wulfie/code/parameter-golf-worktrees/pr824-attn-gate-only/logs/pr824_exploit_20260402_pr824_attn_gate_only.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.68098646`
- `delta vs fresh baseline: -0.01502807`
- `delta vs value-residual-only: +0.00999482`
- `step_avg: 322.27ms`
- `serialized_model_int8_zlib: 15104730 bytes`

Interpretation:

- this baseline is `+0.00321863` worse than the earlier `rerun_wave_20260401` confirm baseline
- that amount of drift is small enough that the wave is still usable, but borderline deltas in the `0.003` range should be treated carefully
- the PR824 positive control still wins by a wide margin and is slightly faster than the fresh baseline in this run, so this wave is healthy enough to trust the value-residual and attn-gate ablations
- `value_residual_only` keeps almost all of the full PR824 gain, so the value path is very likely the dominant mechanism and attention gating should be treated as an incremental add-on unless the next ablation contradicts that
- `attn_gate_only` is still helpful, but materially weaker than `value_residual_only`; the clean working theory now is "value residual is the main lever, attention gate is a smaller stackable gain"
- `pr824_qkgain5` and `pr824_xsa4` were manually stopped because their branch configs did not match the intended experiment definitions, so they should be ignored until repaired

## Active `explore-lite` wave

Fresh wave baseline:

- `/Users/wulfie/code/parameter-golf/logs/explore_lite_20260402_baseline.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.69239991`
- `step_avg: 303.23ms`
- `serialized_model_int8_zlib: 15128268 bytes`

AttnRes-lite:

- `/Users/wulfie/code/parameter-golf-worktrees/attnres-lite/logs/explore_lite_20260402_attnres_lite.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.68501439`
- `delta vs fresh baseline: -0.00738552`
- `step_avg: 315.04ms`
- `serialized_model_int8_zlib: 15311780 bytes`

Hyperconnection-lite:

- `/Users/wulfie/code/parameter-golf-worktrees/hyperconnection-lite/logs/explore_lite_20260402_hyperconnection_lite.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.70267420`
- `delta vs fresh baseline: +0.01027429`
- `step_avg: 301.77ms`
- `serialized_model_int8_zlib: 15129316 bytes`

KGIIR-lite:

- `/Users/wulfie/code/parameter-golf-worktrees/kgiir-lite/logs/explore_lite_20260402_kgiir_lite.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.67562160`
- `delta vs fresh baseline: -0.01677831`
- `step_avg: 318.83ms`
- `serialized_model_int8_zlib: 15173162 bytes`

Interpretation:

- this baseline is close to the historical confirm baseline (`-0.00039599` better than `1.69279590`)
- use this fresh baseline, not the `pr824-exploit` baseline, for `attnres_lite`, `hyperconnection_lite`, and `kgiir_lite`
- `attnres_lite` is a modest but real local win and stays under the 16MB artifact cap, so this residual-routing family deserves one follow-up stack on top of `PR824` or `value-residual-only`
- `hyperconnection_lite` is a clear local miss at this initialization/topology, so drop it for now and keep the residual-routing explore budget on AttnRes-style variants instead
- `kgiir_lite` is a stronger explore win than `attnres_lite` at a manageable speed cost, so the next obvious exploit branch is `PR824/value-residual + KGIIR-lite`

## Completed `next-frontier-lite` wave

Fresh wave baseline:

- `/Users/wulfie/code/parameter-golf/logs/next_frontier_lite_20260402_baseline.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.69574046`
- `step_avg: 325.78ms`
- `serialized_model_int8_zlib: 15143021 bytes`

First value-embedding attempt:

- `/Users/wulfie/code/parameter-golf-worktrees/pr824-value-embedding-lite/logs/next_frontier_lite_20260402_pr824_value_embedding_lite.txt`
- pre-quant `step:4000/4000 val_bpb: 1.6884`
- run exited `1` during `mx.savez` with `RuntimeError: std::bad_cast`
- branch-local fix is prepared; do not score this branch until a clean post-quant rerun lands

PR824 + ParallelResiduals:

- `/Users/wulfie/code/parameter-golf-worktrees/pr824-parallel-residuals/logs/next_frontier_lite_20260402_pr824_parallel_residuals.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.67725281`
- `delta vs fresh baseline: -0.01848765`
- `step_avg: 328.92ms`
- `serialized_model_int8_zlib: 15300798 bytes`

Interpretation:

- this branch is clearly better than the fresh `next-frontier-lite` baseline
- but it is not better than the PR824 mimic positive control from nearby waves, so ParallelResiduals still looks like a standalone win that does not obviously stack on top of the PR824 value/gate core

MoHD last-MLP lite:

- `/Users/wulfie/code/parameter-golf-worktrees/mohd-lastmlp-lite/logs/next_frontier_lite_20260402_mohd_lastmlp_lite.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.69694169`
- `delta vs fresh baseline: +0.00120123`
- `step_avg: 312.02ms`
- `serialized_model_int8_zlib: 15080319 bytes`

Interpretation:

- quality is basically baseline to slightly worse, so this MoHD-style tail-channel gate is not worth another local slot unless we redesign the gate form or combine it with the value-residual family differently

## Completed `pr824-fixups` wave

Fresh wave baseline:

- `/Users/wulfie/code/parameter-golf/logs/pr824_fixups_20260402_baseline.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.69615068`
- `step_avg: 310.25ms`
- `serialized_model_int8_zlib: 15136050 bytes`

PR824 mimic positive control:

- `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid/logs/pr824_fixups_20260402_pr824_mimic.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.66833719`
- `delta vs fresh baseline: -0.02781349`
- `step_avg: 336.05ms`
- `serialized_model_int8_zlib: 15336584 bytes`

PR824 + QK_GAIN=5.0:

- `/Users/wulfie/code/parameter-golf-worktrees/pr824-qkgain5/logs/pr824_fixups_20260402_pr824_qkgain5.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.66190993`
- `delta vs fresh baseline: -0.03424075`
- `delta vs PR824 mimic: -0.00642726`
- `step_avg: 333.05ms`
- `serialized_model_int8_zlib: 15403892 bytes`

Interpretation:

- this is the best local result so far and the first QK-gain variant with a clear positive signal when stacked on the PR824 value/gate core

PR824 with XSA last 4:

- `/Users/wulfie/code/parameter-golf-worktrees/pr824-xsa4/logs/pr824_fixups_20260402_pr824_xsa4.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.66929723`
- `delta vs fresh baseline: -0.02685345`
- `delta vs PR824 mimic: +0.00096004`
- `step_avg: 327.47ms`
- `serialized_model_int8_zlib: 15330969 bytes`

Interpretation:

- `XSA_LAST_N=4` is still a clear win over the baseline and slightly faster/smaller than the full PR824 mimic branch, but the quality drop relative to XSA6 is large enough that this is an ablation result, not the current best exploit path

## Paused after partial `pr824-stacks` wave

Fresh wave baseline:

- `/Users/wulfie/code/parameter-golf/logs/pr824_stacks_20260402_baseline.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.69449315`
- `step_avg: 340.85ms`
- `serialized_model_int8_zlib: 15135923 bytes`

PR824 mimic positive control:

- `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid/logs/pr824_stacks_20260402_pr824_mimic.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.66770976`
- `delta vs fresh baseline: -0.02678339`
- `step_avg: 321.79ms`
- `serialized_model_int8_zlib: 15335597 bytes`

PR824 + KGIIR-lite:

- `/Users/wulfie/code/parameter-golf-worktrees/pr824-kgiir-lite/logs/pr824_stacks_20260402_pr824_kgiir_lite.txt`
- `final_int8_zlib_roundtrip_exact val_bpb: 1.65947391`
- `delta vs fresh baseline: -0.03501924`
- `delta vs PR824 mimic: -0.00823585`
- `delta vs previous best pr824_qkgain5: -0.00243602`
- `step_avg: 348.85ms`
- `serialized_model_int8_zlib: 15353184 bytes`

Interpretation:

- this is the best local result so far and the strongest evidence yet that a lightweight temporal mixer can compose positively with the PR824 value/gate/XSA path
- the tradeoff is a moderate speed slowdown versus plain PR824 mimic and `pr824-qkgain5`

PR824 + AttnRes-lite:

- startup failure:
  - `TypeError: GPT.__init__() got an unexpected keyword argument 'attnres_enable'`
  - stderr: `/Users/wulfie/code/parameter-golf/logs/pr824_stacks_20260402_pr824_attnres_lite.stderr.txt`

Interpretation:

- this branch is currently blocked by a constructor/plumbing bug, so the failed run should not be interpreted as a quality result

Queued in this wave:

- `pr824_mimic`
- `pr824_kgiir_lite`
- `pr824_attnres_lite`
