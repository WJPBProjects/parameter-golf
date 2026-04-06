# Experiment Note

## Experiment

- Name: PR824 mimic: XSA6 + GatedAttn + ValueResid
- Status: PASS
- Owner: `main-agent`
- Branch: `codex/pr824-mimic-gatedattn-valueresid`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/pr824-mimic-gatedattn-valueresid/train_gpt.py`
  - `experiments/pr824-mimic-gatedattn-valueresid/train_gpt_mlx.py`

## Hypothesis

- A partial mimic of a strong public PR should improve the local harness too if the harness is directionally useful.

## Scope

- Files changed:
  - `experiments/pr824-mimic-gatedattn-valueresid/train_gpt.py`
  - `experiments/pr824-mimic-gatedattn-valueresid/train_gpt_mlx.py`
- Local screen command(s):
  - `SEED=1337 RUN_ID=pr824_mimic_long_seed1337 TRAIN_MLX_SCRIPT=experiments/pr824-mimic-gatedattn-valueresid/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh`
- Remote run command(s):
  - `TBD`

## Progress

- This is the current strongest local positive control.
- The improvement persisted on the stronger longer local harness.
- Ablations point to `value_residual` as the main source of the gain, with `attn_gate` stacking on top.

## Local Screening

- Status: PASS
- Date: `2026-03-27`
- Seed(s): `1337`
- Log path:
  - `logs/pr824_mimic_long_seed1337.txt`
- Artifact path(s):
  - `logs/pr824_mimic_long_seed1337_mlx_model.npz`
  - `logs/pr824_mimic_long_seed1337_mlx_model.int8.ptz`
- Throughput / wallclock:
  - `280.59ms/step`
- Val / BPB:
  - baseline on same harness: `2.15725007`
  - mimic: `2.10420259`
- Notes:
  - Delta vs baseline: `-0.05304748 val_bpb`
  - `XSA6` alone did not help.
  - `value_residual` drove most of the gain.

## Fresh confirm check

- Run tag: `pr824_exploit_20260402`
- Date: `2026-04-02`
- Log path:
  - `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid/logs/pr824_exploit_20260402_pr824_mimic.txt`
- Fresh baseline:
  - `/Users/wulfie/code/parameter-golf/logs/pr824_exploit_20260402_baseline.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69601453`
- Positive-control result:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.66814857`
  - `step_avg: 310.41ms`
  - `serialized_model_int8_zlib: 15336317 bytes`
- Interpretation:
  - Still a strong win versus the fresh wave baseline (`-0.02786596 bpb`).
  - This keeps PR824 mimic valid as the main positive control for the current exploit wave.

## Promotion Decision

- Promote to remote: HOLD
- Reason:
  - Clear local win, but remote stage-3 validation regressed versus the same-pod CUDA baseline.
- Remote priority: medium

## Remote Training

- Status: FAIL
- Date: `2026-04-06`
- Seed(s): `1337`
- Machine / provider:
  - `RunPod 1xH100`
- Run identifier:
  - `remote_pr824-kgiir-lite_control_20260406_153725`
- Log path:
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/control/logs/remote_pr824-kgiir-lite_control_20260406_153725.txt`
- Artifact path(s):
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/control/artifacts/final_model.int8.ptz`
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/control/artifacts/final_model.pt`
- Pre-quant:
  - `val_bpb: 1.3418`
- Post-quant:
  - `val_bpb: 1.34315176`
- Speed / wallclock:
  - `516.81ms/step`
  - stopped at `step 1161` on the `600s` wallclock cap
- Artifact size:
  - `12946687 bytes`
- Notes:
  - Same-pod baseline for this shakedown was `1.33471717`, so the remote result is directionally worse despite strong local wins.

## Results Summary

- Pre-quant:
  - local confirm best: `1.66814857`
  - remote stage-3: `1.3418`
- Post-quant:
  - remote stage-3: `1.34315176`
- Speed / wallclock:
  - remote `516.81ms/step`
- Artifact size:
  - `12946687 bytes`

## Conclusion

- This is still a valid local positive control, but it is not a remote positive control. The local harness can rank ideas, but this branch shows that local wins do not automatically transfer to CUDA.

## Next step

- Use this as a warning case, not as a submission candidate. Any next PR824-family branch now needs remote validation before it is trusted.
