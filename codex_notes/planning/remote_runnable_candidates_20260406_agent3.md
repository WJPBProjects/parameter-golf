# Remote-Runnable Candidate Audit - 2026-04-06

Scope: audited branch state that the remote `8xH100` runner can fetch from `origin`. This intentionally excludes untracked experiment directories and local-only branches, even if they have promising local logs.

Current main worktree note: `main` has unrelated active-run edits in `codex_notes/coordination/submission_reference_curve.tsv` and remote runner scripts. I did not touch queue files.

## Criteria

- Branch is present on `origin`.
- Branch contains a tracked `experiments/<name>/train_gpt.py`, or the intended trainer path is already tracked in the branch tree.
- `python3 -m py_compile` passes for the selected trainer snapshot.
- Candidate has enough novelty/value to justify possible `8xH100` spend.

## Top 5

| Rank | Branch | Commit | Train script | Suggested env | Reason | Blockers / cautions |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `codex/late-value-embed-qk5` | `origin/codex/late-value-embed-qk5@e584529` | `experiments/late-value-embed-qk5/train_gpt.py` | `VE_ENABLED=1 VE_DIM=128 VE_LAYERS=7,8 QK_GAIN_INIT=5.0 VAL_LOSS_EVERY=1500` | Best novel/high-upside branch currently fetchable. It combines the value-embedding direction from small-model research with QK gain, without being a straight public PR clone. Trainer is tracked and syntax-checks. | No local result found in `late-value-embed-qk5/logs`; spend only after the shared `8xH100` reference is established or as a deliberate high-upside explore slot. |
| 2 | `codex/parallel-residuals-pr1204` | `origin/codex/parallel-residuals-pr1204@b5fa6b9` | `experiments/parallel-residuals-pr1204/train_gpt.py` | `QK_GAIN_INIT=5.0 PARALLEL_RESIDUAL=1 PARALLEL_START_LAYER=6 VAL_LOSS_EVERY=1500` | Strongest clean neural-topology direction that tracks the current public frontier without copying it outright. Local MLX confirm with QK gain finished at `final_int8_zlib_roundtrip_exact val_bpb: 1.68638383`; older plain parallel-residual local result was `1.67852834`. Trainer is tracked, pushed, and syntax-checks. | Local QK-gain rerun was worse than older plain parallel residual; still strategically valuable because it is remote-capable and closer to recurrence/parallel-residual frontier. |
| 3 | `codex/compile-safe-late-qat` | `origin/codex/compile-safe-late-qat@cf5aa84` | `experiments/compile-safe-late-qat/train_gpt.py` | `QAT_ENABLED=1 LATE_QAT_THRESHOLD=0.15 VAL_LOSS_EVERY=1500` | Remote-only systems/quantization hypothesis that cannot be judged on MLX. Branch is pushed, has tracked CUDA trainer, and syntax-checks. Useful because it probes post-quantization loss, which is directly relevant to the artifact-scored run. | No meaningful local validation. Worktree has local script symlink/untracked-script noise, but the origin branch itself has the trainer tracked. Must set `QAT_ENABLED=1`; otherwise it behaves like the base trainer. |
| 4 | `codex/xsa-all` | `origin/codex/xsa-all@84823e7` | `experiments/xsa-all/train_gpt.py` | `XSA_LAST_N=9 VAL_LOSS_EVERY=1500` | Fetchable, tracked, and syntax-checks. Local confirm rerun was a small quality win (`1.68548359` vs confirm baseline `1.69279590`) and an earlier shorter local screen was strongly positive. | Weak novelty and poor local speed tradeoff (`step_avg` around `460ms` on local confirm). Must set `XSA_LAST_N=9`; default is `0`, which would run the baseline path. Use only as a low-priority calibration/ingredient run. |
| 5 | `codex/pr824-mimic-gatedattn-valueresid` | `origin/codex/pr824-mimic-gatedattn-valueresid@1a3b628` | `experiments/pr824-mimic-gatedattn-valueresid/train_gpt.py` | `VAL_LOSS_EVERY=1500` | Remote-runnable positive-control/ingredient branch with the strongest historical local signal among tracked pushed branches (`1.6677`-ish local confirm family). Useful to compare whether value-residual/gated-attention still transfers on true `8xH100`, not the broken `1xH100` proxy. | Not a novel final submission target, and old `1xH100` shakedown was directionally bad. Use only if we want a control or ingredient signal, not as the main leaderboard attempt. |

## Explicitly not top-5 despite being pushed

- `codex/pr824-kgiir-lite@ac9577c`: pushed, but the branch does **not** track `experiments/pr824-kgiir-lite/train_gpt.py`. The remote runner would not run the intended KGIIR code from `origin`.
- `codex/gptq-self-calibration@9f36a2f`: fetchable and has a tracked trainer, but longer local confirm variants were worse than baseline.
- `codex/rope-lnscale-grid@5e9494a`: fetchable and has a tracked trainer, but the screened point was clearly worse locally.
- `codex/selective-post-gptq-pruning@cf2deb7`: fetchable and has a tracked trainer, but quality regressed locally.
- `codex/splineconv-hybrid@acc0f32`: fetchable and has a tracked trainer, but local confirm was basically flat/worse and is lower strategic value.
- `codex/leakyrelu-slope-sweep@7b9ce0e`: fetchable and has a tracked trainer, but local result was flat to slightly worse.

## Local-only or not currently fetchable

- `codex/late-value-embed-legal-ttt@cb42c4c`: now pushed after this audit was written. It adds legal score-first TTT on top of the fetchable `late-value-embed-qk5` branch and is queued in `submission_batch_queue_c.tsv`.
- `codex/pr824-qkgain5-kgiir-lite`: has a tracked-looking local experiment and a good local result, but no `origin/codex/pr824-qkgain5-kgiir-lite`; not remote-runnable until pushed.
- `codex/pr824-attnres-lite`: local branch only; origin branch missing. It also only had `train_gpt_mlx.py` tracked in the branch snapshot checked earlier.
- `codex/pr824-value-residual-only`: local branch only; no origin branch.
- `codex/pr824-qkgain5`: local branch only; no origin branch.
- `codex/pr824-value-embedding-lite`: local branch only, MLX path recently failed with an optimizer tree issue, and the remote trainer state is not pushed.
