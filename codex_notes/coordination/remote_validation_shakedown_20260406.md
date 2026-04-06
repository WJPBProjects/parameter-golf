# Remote Validation Shakedown (2026-04-06)

## Goal

- Prove the stage-3 RunPod validation loop works end to end:
  - start a validation pod
  - run same-pod baseline
  - run same-pod PR824 mimic positive control
  - run same-pod candidate
  - pull logs and artifacts back locally
  - stop the pod cleanly

## Pod and run

- Pod:
  - `2ollt57dzbud46`
  - `parameter-golf-h100-b`
- Provider:
  - `RunPod`
- Machine:
  - `1xH100`
- Local result directory:
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite`

## Remote results

| Stage | Run id | Post-quant val_bpb | Step avg | Artifact bytes | Verdict |
|---|---|---:|---:|---:|---|
| baseline | `remote_pr824-kgiir-lite_baseline_20260406_153725` | `1.33471717` | `455.65ms` | `13508130` | reference |
| control: PR824 mimic | `remote_pr824-kgiir-lite_control_20260406_153725` | `1.34315176` | `516.81ms` | `12946687` | remote regression |
| candidate: PR824 + KGIIR-lite | `remote_pr824-kgiir-lite_candidate_20260406_153725` | `1.34130189` | `488.60ms` | `13193091` | remote regression |

## Key takeaways

- The remote validation workflow now works end to end.
- The local positive control did **not** transfer directionally on remote:
  - baseline `1.33471717`
  - PR824 mimic `1.34315176`
- The current best local candidate also did **not** beat the remote baseline:
  - PR824 + KGIIR-lite `1.34130189`
- Candidate was slightly better than the PR824 control remotely, but still clearly worse than the same-pod baseline.
- Conclusion:
  - local MLX remains useful for cheap filtering
  - but this family is not yet trustworthy as a remote winner
  - we now need fresh remote-positive controls before spending a full 24-hour lane

## Local artifacts pulled back

- Baseline:
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/baseline/logs/remote_pr824-kgiir-lite_baseline_20260406_153725.txt`
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/baseline/logs/remote_pr824-kgiir-lite_baseline_20260406_153725.summary.txt`
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/baseline/artifacts/final_model.int8.ptz`
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/baseline/artifacts/final_model.pt`
- Control:
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/control/logs/remote_pr824-kgiir-lite_control_20260406_153725.txt`
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/control/logs/remote_pr824-kgiir-lite_control_20260406_153725.summary.txt`
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/control/artifacts/final_model.int8.ptz`
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/control/artifacts/final_model.pt`
- Candidate:
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/candidate/logs/remote_pr824-kgiir-lite_candidate_20260406_153725.txt`
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/candidate/logs/remote_pr824-kgiir-lite_candidate_20260406_153725.summary.txt`
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/candidate/artifacts/final_model.int8.ptz`
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_153725_pr824-kgiir-lite/candidate/artifacts/final_model.pt`

## Workflow bugs fixed during shakedown

- remote repo bootstrap now handles pre-existing non-git `/workspace/parameter-golf`
- remote wrappers now tee `torchrun` into the claimed log path
- pullback helper now auto-resolves the local RunPod SSH key
- validation sequence can resume from `control` or `candidate` after a laptop restart
- remote stage switching now cleans disposable outputs and untracked non-ignored files
- remote stage runner is fetched from `origin/main`, not assumed to exist on every experiment branch
- remote trainer path now falls back to the branch root trainer when the experiment-local path is absent on `origin`

## Recommended next step

- Do **not** spend the 8xH100 lane on the PR824 mimic / PR824 + KGIIR-lite family as-is.
- First find at least one remote-positive stage-3 branch that beats the same-pod baseline.
