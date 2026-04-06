# Experiment Note

## Experiment

- Name: PR824 + KGIIR-lite
- Status: FAIL
- Owner: `main-agent`
- Branch: `codex/pr824-kgiir-lite`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/pr824-kgiir-lite`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/pr824-kgiir-lite/train_gpt.py`
  - `experiments/pr824-kgiir-lite/train_gpt_mlx.py`
  - remote fallback used branch-root `train_gpt.py` because the experiment-local trainer was not present on `origin`

## Hypothesis

- The strongest local exploit branch should stay positive on remote stage-3 validation if it is a real leaderboard candidate.

## Scope

- Files expected to change:
  - `train_gpt.py`
  - experiment-local copies on the branch
- Local screen command(s):
  - `SEED=1337 RUN_ID=pr824_stacks_20260402_pr824_kgiir_lite TRAIN_MLX_SCRIPT=experiments/pr824-kgiir-lite/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh`
- Remote run command(s):
  - `START_STAGE=candidate BASELINE_RUN_ID=remote_pr824-kgiir-lite_baseline_20260406_153725 CONTROL_RUN_ID=remote_pr824-kgiir-lite_control_20260406_153725 STAMP=20260406_153725 bash scripts/run_remote_validation_sequence.sh root@103.207.149.118 pr824-kgiir-lite codex/pr824-kgiir-lite experiments/pr824-kgiir-lite/train_gpt.py`

## Progress

- This was the best local branch before remote validation.
- It completed a same-pod RunPod stage-3 validation sequence after the orchestration bugs were fixed.

## Local Screening

- Status: PASS
- Date: `2026-04-02`
- Seed(s): `1337`
- Log path:
  - `/Users/wulfie/code/parameter-golf-worktrees/pr824-kgiir-lite/logs/pr824_stacks_20260402_pr824_kgiir_lite.txt`
- Artifact path(s):
  - local log contains `serialized_model_int8_zlib: 15353184 bytes`
- Throughput / wallclock:
  - `348.85ms/step`
- Val / BPB:
  - wave baseline: `1.69449315`
  - branch: `1.65947391`
- Notes:
  - Best local result so far at the time of screening.

## Promotion Decision

- Promote to remote: HOLD
- Reason:
  - The remote stage-3 run finished cleanly but did not beat the same-pod CUDA baseline.
- Remote priority: medium

## Remote Training

- Status: FAIL
- Date: `2026-04-06`
- Seed(s): `1337`
- Machine / provider:
  - `RunPod 1xH100`
- Run identifier:
  - `remote_pr824-kgiir-lite_candidate_20260406_153725`
- Log path:
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/candidate/logs/remote_pr824-kgiir-lite_candidate_20260406_153725.txt`
- Artifact path(s):
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/candidate/artifacts/final_model.int8.ptz`
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/candidate/artifacts/final_model.pt`
- Pre-quant:
  - `val_bpb: 1.3400`
- Post-quant:
  - `val_bpb: 1.34130189`
- Speed / wallclock:
  - `488.60ms/step`
  - stopped at `step 1228` on the `600s` wallclock cap
- Artifact size:
  - `13193091 bytes`
- Notes:
  - Same-pod baseline was `1.33471717`.
  - Same-pod PR824 mimic control was `1.34315176`.
  - Candidate is slightly better than the control but still clearly worse than the baseline.

## Results Summary

- Pre-quant:
  - local confirm: `1.65947391`
  - remote stage-3: `1.3400`
- Post-quant:
  - remote stage-3: `1.34130189`
- Speed / wallclock:
  - remote `488.60ms/step`
- Artifact size:
  - `13193091 bytes`

## Conclusion

- This branch is a strong example of a local exploit win that did not survive remote validation. It should not be promoted to stage 4 in its current form.

## Next step

- Treat this family as unresolved remotely. The next remote slot should go to a different local family or a much simpler remote-positive control.
