# Remote Experiment Playbook

This file is the operator README for promoted CUDA runs.

Use it together with:

- `codex_notes/coordination_live/experiment_board.md`
- `codex_notes/coordination_live/remote_pod_inventory.md`
- `codex_notes/coordination_live/promotion_rubric.md`
- `codex_notes/coordination_live/remote_run_queue.md`

## Goal

Run promoted experiments on remote CUDA machines in a way that is:

- comparable across experiments
- restart-safe
- easy to audit afterward

## Current calibration policy

Do not use a partial public-PR port as the default remote control.

The default same-pod control is now the exact merged record:

- `records/track_10min_16mb/2026-03-22_11L_EMA_GPTQ-lite_warmdown3500_QAT015_1.1233/train_gpt.py`

Reason:

- it is merged
- it is valid
- it is reproducible from `main`
- it gives a cleaner remote calibration target than an approximate branch port

## Promotion ladder

1. local screen
2. local confirm
3. remote validation on cheaper CUDA, usually `1xH100`
4. true submission-style remote run on `8xH100 SXM`

## Concurrency policy

- Stage 3 validation may use up to `3` concurrent `1xH100` pods.
- Stage 4 is single-lane only.
- Keep submission pods stopped unless actively needed.

## Standard stage-3 sequence

For each fresh validation pod or major code refresh:

1. same-pod baseline
2. same-pod exact merged-record control
3. one or more promoted candidates
4. extra seeds only for candidates that still look promising remotely

Do not evaluate a candidate without a fresh same-pod baseline first.

## Standard scripts

- stage-3 runner:
  - `scripts/run_remote_experiment.sh`
- artifact pullback:
  - `scripts/pull_remote_run_artifacts.sh`
- local queue helper:
  - `scripts/run_remote_validation_sequence.sh`
- automatic pod claim:
  - `scripts/claim_remote_validation_pod.sh`
- automatic pod release:
  - `scripts/release_remote_validation_pod.sh`
- stage-4 runner:
  - `scripts/run_remote_submission_8xh100.sh`

## What counts as a valid remote result

A remote result is only valid if all of the following are true:

- `logs/<RUN_ID>.txt` exists
- the log contains `final_int8_zlib_roundtrip_exact`
- the log contains `serialized_model_int8_zlib`
- the compared runs were executed on the same pod session
- the recorded trainer path matches the intended script

If any of those are missing, mark the run `BLOCKED` or `FAIL`, not `DONE`.

## Pod bootstrap

On a fresh pod:

```bash
cd /workspace
git clone https://github.com/openai/parameter-golf.git
cd parameter-golf
python3 data/cached_challenge_fineweb.py --variant sp1024
```

If the experiment is on a non-`main` branch, push it locally and fetch it remotely before running.

## Standard runner examples

Baseline:

```bash
bash scripts/run_remote_experiment.sh baseline train_gpt.py
```

Merged-record control:

```bash
bash scripts/run_remote_experiment.sh \
  merged-record-signalrush \
  records/track_10min_16mb/2026-03-22_11L_EMA_GPTQ-lite_warmdown3500_QAT015_1.1233/train_gpt.py
```

Candidate:

```bash
bash scripts/run_remote_experiment.sh \
  compile-safe-late-qat \
  experiments/compile-safe-late-qat/train_gpt.py
```

## Queue helper

The local helper can run baseline -> merged-record control -> candidate in one pass:

```bash
bash scripts/run_remote_validation_sequence.sh \
  auto \
  compile-safe-late-qat \
  codex/compile-safe-late-qat \
  experiments/compile-safe-late-qat/train_gpt.py
```

It will:

- claim a stopped validation pod
- start it
- resolve the live SSH endpoint
- bootstrap repo and data if needed
- run the three-stage sequence
- pull back logs and artifacts into `remote_results/`
- stop and release the pod by default

## Restart-safe resume

If a laptop restart interrupts a sequence, resume from `control` or `candidate`:

```bash
START_STAGE=control \
SKIP_REMOTE_SETUP=1 \
BASELINE_RUN_ID=remote_compile-safe-late-qat_baseline_20260406_153725 \
bash scripts/run_remote_validation_sequence.sh \
  root@<ip> \
  compile-safe-late-qat \
  codex/compile-safe-late-qat \
  experiments/compile-safe-late-qat/train_gpt.py
```

Use:

- `START_STAGE=control` to skip baseline
- `START_STAGE=candidate` to skip baseline and control
- `BASELINE_RUN_ID=...` and `CONTROL_RUN_ID=...` to pull already-finished outputs into the local result directory

## Validation-pod guard rails

The normal stage-3 flow is:

1. claim a pod
2. only claim pods whose RunPod status is `EXITED`
3. treat already-running pods as busy
4. release and stop them after the batch

This is safe for multiple local agents on this machine and conservative against pods started elsewhere.

## Artifact pullback

After each remote run, pull back at least:

- `logs/<RUN_ID>.txt`
- `logs/<RUN_ID>.remote.meta.txt`
- `logs/<RUN_ID>.summary.txt`
- `artifacts/<RUN_ID>/final_model.int8.ptz`

For serious runs, also pull back:

- `artifacts/<RUN_ID>/final_model.pt`

## Practical rule

Keep one validation pod warm for an active batch. Do not create a fresh pod per candidate unless capacity forces it.
