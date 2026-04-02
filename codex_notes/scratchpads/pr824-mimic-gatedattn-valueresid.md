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

- Promote to remote: READY
- Reason:
  - Clear local win and good positive-control behavior for the harness.
- Remote priority: high

## Remote Training

- Status: TODO

## Conclusion

- This is the strongest evidence so far that the local MLX harness can detect a real directionally correct improvement.

## Next step

- Mine the same family further with `value_residual` and related value-path ideas.
