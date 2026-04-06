# Remote Experiment Playbook

This file is the operator README for promoted CUDA runs.

Use it together with:

- `codex_notes/coordination_live/experiment_board.md`
- `codex_notes/coordination_live/remote_pod_inventory.md`
- `codex_notes/coordination_live/promotion_rubric.md`
- `codex_notes/coordination_live/remote_run_queue.md`
- the experiment's own scratchpad

## Goal

Run promoted experiments on a remote CUDA box in a way that is:

- comparable across experiments
- easy for another agent to resume
- easy to judge after the fact

## Concurrency policy

- Stage 3 remote validation may use up to `3` concurrent `1xH100` pods.
- Those three pods are the normal validation fleet recorded in `remote_pod_inventory.md`.
- Stage 4 true submission runs on `8xH100` are single-lane only.
- Run at most `one` `8xH100` submission job at a time.
- Do not launch a second `8xH100` submission pod or a second submission-stage job in parallel unless the user explicitly asks for it.

## Promotion ladder

The intended four-stage flow in this repo is:

1. local screen
2. local confirm
3. remote validation on cheaper CUDA, usually `1xH100`
4. true submission-style remote run on `8xH100 SXM`

Current scripts:

- local screen:
  - `scripts/run_local_screen_mlx.sh`
- local confirm:
  - `scripts/run_local_confirm_mlx.sh`
- optional deeper local pass:
  - `scripts/run_local_overnight_mlx.sh`
- remote validation:
  - `scripts/run_remote_experiment.sh`
- true `8xH100` submission-style run:
  - `scripts/run_remote_submission_8xh100.sh`
- helper to create the `8xH100` RunPod:
  - `scripts/create_remote_submission_pod.sh`

## Default remote sequence

For each new pod or major code refresh, run in this order:

1. same-pod baseline sanity run
2. same-pod positive control run
3. top promoted candidate(s)
4. extra seeds only for candidates that still look promising remotely

Do not jump straight to a candidate branch without a fresh baseline on the same pod.

## What counts as a valid remote result

A remote run is only considered complete if all of these are true:

- `logs/<RUN_ID>.txt` exists
- the log contains `final_int8_zlib_roundtrip_exact`
- the log contains `serialized_model_int8_zlib`
- the startup config matches the intended branch and trainer path
- the run is compared against a same-pod baseline, not only an older local MLX result

If any of those are missing, mark the remote run `BLOCKED` or `FAIL`, not `DONE`.

## Standard pod setup

From the pod, for a brand new ephemeral machine:

```bash
cd /workspace
git clone https://github.com/openai/parameter-golf.git
cd parameter-golf
python3 data/cached_challenge_fineweb.py --variant sp1024
```

If the promoted experiment lives on a non-default branch, get that branch onto the pod before running it.

Preferred path:

1. push the experiment branch from the local machine
2. fetch it on the pod
3. run the experiment-local trainer copy from that branch

Example from the local machine:

```bash
cd /Users/wulfie/code/parameter-golf-worktrees/pr824-kgiir-lite
git status
git push -u origin codex/pr824-kgiir-lite
```

Example from the pod:

```bash
cd /workspace/parameter-golf
git fetch origin
git fetch origin codex/pr824-kgiir-lite
git switch -C codex/pr824-kgiir-lite --track origin/codex/pr824-kgiir-lite
```

Repeat the same pattern for any other promoted branch.

## Standard runner

Use the wrapper script so remote runs produce a consistent `RUN_ID`, metadata file, and summary file:

```bash
bash scripts/run_remote_experiment.sh <experiment-slug> <train-script>
```

The wrapper writes:

- `logs/<RUN_ID>.txt`
- `logs/<RUN_ID>.remote.meta.txt`
- `logs/<RUN_ID>.summary.txt`
- `artifacts/<RUN_ID>/final_model.pt` when present
- `artifacts/<RUN_ID>/final_model.int8.ptz` when present

Defaults:

- `DATA_PATH=./data/datasets/fineweb10B_sp1024/`
- `TOKENIZER_PATH=./data/tokenizers/fineweb_1024_bpe.model`
- `VOCAB_SIZE=1024`
- `SEED=1337`
- `VAL_LOSS_EVERY=0`
- `MAX_WALLCLOCK_SECONDS=600`
- `NPROC_PER_NODE=1`

Override them in the shell only when the experiment explicitly needs it.

This script is for stage 3 only. It is not the final leaderboard-faithful `8xH100` runner.

## True remote submission runner

For the final stage, use:

```bash
bash scripts/run_remote_submission_8xh100.sh <experiment-slug> <train-script>
```

This runner:

- requires exactly `8` visible GPUs
- uses `torchrun --nproc_per_node=8`
- preserves the challenge-style `600` second wallclock cap by default
- writes the same style of logs, summaries, and artifact directories as the cheaper remote runner
- is intended to run as the only active submission-stage job

To create the matching RunPod shape, use:

```bash
bash scripts/create_remote_submission_pod.sh
```

Optional overrides:

```bash
POD_NAME=parameter-golf-8xh100-a \
DATA_CENTER_IDS=AP-IN-1 \
bash scripts/create_remote_submission_pod.sh
```

Submission-stage policy:

- create only one `8xH100` pod
- run only one submission-stage experiment at a time
- stop that pod when the run and immediate inspection are finished

## Canonical first runs

Baseline:

```bash
bash scripts/run_remote_experiment.sh baseline train_gpt.py
```

PR824 mimic positive control:

```bash
bash scripts/run_remote_experiment.sh \
  pr824-mimic \
  experiments/pr824-mimic-gatedattn-valueresid/train_gpt.py
```

Current best local candidate:

```bash
bash scripts/run_remote_experiment.sh \
  pr824-kgiir-lite \
  experiments/pr824-kgiir-lite/train_gpt.py
```

Second best local candidate:

```bash
bash scripts/run_remote_experiment.sh \
  pr824-qkgain5 \
  experiments/pr824-qkgain5/train_gpt.py
```

CUDA-specific branch that local MLX cannot fairly judge:

```bash
QAT_ENABLED=1 LATE_QAT_THRESHOLD=0.15 \
bash scripts/run_remote_experiment.sh \
  compile-safe-late-qat \
  experiments/compile-safe-late-qat/train_gpt.py
```

True `8xH100` submission-style run:

```bash
bash scripts/run_remote_submission_8xh100.sh \
  pr824-kgiir-lite \
  experiments/pr824-kgiir-lite/train_gpt.py
```

## End-to-end exact command sequence

Example for a fresh pod and the current top candidate:

```bash
cd /workspace
git clone https://github.com/openai/parameter-golf.git
cd parameter-golf
python3 data/cached_challenge_fineweb.py --variant sp1024

bash scripts/run_remote_experiment.sh baseline train_gpt.py

git fetch origin codex/pr824-mimic-gatedattn-valueresid
git switch -C codex/pr824-mimic-gatedattn-valueresid --track origin/codex/pr824-mimic-gatedattn-valueresid
bash scripts/run_remote_experiment.sh pr824-mimic experiments/pr824-mimic-gatedattn-valueresid/train_gpt.py

git fetch origin codex/pr824-kgiir-lite
git switch -C codex/pr824-kgiir-lite --track origin/codex/pr824-kgiir-lite
bash scripts/run_remote_experiment.sh pr824-kgiir-lite experiments/pr824-kgiir-lite/train_gpt.py
```

Example for the next promoted branch on the same pod:

```bash
cd /workspace/parameter-golf
git fetch origin codex/pr824-qkgain5
git switch -C codex/pr824-qkgain5 --track origin/codex/pr824-qkgain5
bash scripts/run_remote_experiment.sh pr824-qkgain5 experiments/pr824-qkgain5/train_gpt.py
```

To inspect the result quickly:

```bash
tail -n 40 logs/remote_pr824-kgiir-lite_*.summary.txt
tail -n 80 logs/remote_pr824-kgiir-lite_*.txt
ls -lh artifacts/remote_pr824-kgiir-lite_*/
```

## How to judge the result

First compare against the same-pod baseline.

Then compare against the same-pod PR824 mimic positive control if the candidate is in the current exploit family.

Record at minimum:

- exact branch and commit
- exact command
- `final_int8_zlib_roundtrip_exact val_bpb`
- `serialized_model_int8_zlib`
- training `step_avg` if present
- whether the result beat the same-pod baseline
- whether it beat the same-pod positive control

## Promotion thresholds after the first remote run

Treat the branch as worth more remote spend when at least one is true:

- it clearly beats the same-pod baseline
- it beats the current same-pod positive control
- it is CUDA-specific and behaves credibly enough to justify one more confirm run

Escalate from stage 3 to stage 4 only when:

- the branch beats the same-pod baseline remotely
- it is at least competitive with the current same-pod positive control
- it is worth the cost of a true `8xH100` run

Treat the branch as not worth more remote spend when any of these are true:

- it loses to the same-pod baseline
- it exceeds the `16,000,000` byte cap without a compelling compensating gain
- the run only wins locally but loses remotely without a clear explanation

## Multi-seed follow-up

Only do multiple seeds after a successful first remote run.

Suggested follow-up seeds:

- `1337`
- `42`
- `2025`

Run the same trainer path and same pod type. Do not change multiple knobs between seeds.

Exact example:

```bash
cd /workspace/parameter-golf
git switch codex/pr824-kgiir-lite
SEED=42 RUN_ID=remote_pr824-kgiir-lite_seed42 bash scripts/run_remote_experiment.sh pr824-kgiir-lite experiments/pr824-kgiir-lite/train_gpt.py
SEED=2025 RUN_ID=remote_pr824-kgiir-lite_seed2025 bash scripts/run_remote_experiment.sh pr824-kgiir-lite experiments/pr824-kgiir-lite/train_gpt.py
```

## Pod lifecycle and cost control

Do not leave a GPU pod running just because the repo is already cloned.

For the RunPod configuration shown in the setup screenshots:

- stopping the pod stops GPU billing
- `/workspace` on the volume disk persists across stop/start
- container-disk temporary storage is erased when the pod is stopped
- terminating or deleting the pod deletes the volume disk tied to that pod

Practical rule:

- stop the pod when you are not actively running or inspecting a job
- keep the pod only if you expect to resume soon and want to preserve `/workspace`
- terminate the pod only after copying out any logs or artifacts you still need

From the local machine with `runpodctl`:

```bash
runpodctl pod list
runpodctl pod stop <pod_id>
runpodctl pod start <pod_id>
runpodctl pod get <pod_id>
```

Use the recorded pod ids in:

- `codex_notes/coordination_live/remote_pod_inventory.md`

That means yes, you can spin pods up and down on demand. For cost control, that should be the default.

For the true submission stage, do not create or start an `8xH100` pod casually. That stage is materially more expensive than the 1xH100 validation fleet.

## Parallelism

Yes, remote experiments can run in parallel, but only if the hardware layout supports it cleanly.

### Safe parallel option A: multiple pods

This is the cleanest setup.

- one pod per experiment
- one branch checked out per pod
- one active training run per pod

This keeps metrics comparable and avoids GPU contention.

In this repo, that means up to `3` concurrent validation runs because there are currently three `1xH100` validation pods.

### Safe parallel option B: one multi-GPU pod, one run per GPU

This is only appropriate if the pod has more than one GPU.

Requirements:

- separate branch or worktree per experiment inside the pod
- one process pinned per GPU with `CUDA_VISIBLE_DEVICES`
- distinct `RUN_ID`s
- distinct shell sessions

Example on a 2-GPU pod:

```bash
cd /workspace
git clone https://github.com/openai/parameter-golf.git parameter-golf-pr824-kgiir-lite
git clone https://github.com/openai/parameter-golf.git parameter-golf-pr824-qkgain5
```

In shell 1:

```bash
cd /workspace/parameter-golf-pr824-kgiir-lite
git fetch origin codex/pr824-kgiir-lite
git switch -C codex/pr824-kgiir-lite --track origin/codex/pr824-kgiir-lite
CUDA_VISIBLE_DEVICES=0 NPROC_PER_NODE=1 bash scripts/run_remote_experiment.sh pr824-kgiir-lite experiments/pr824-kgiir-lite/train_gpt.py
```

In shell 2:

```bash
cd /workspace/parameter-golf-pr824-qkgain5
git fetch origin codex/pr824-qkgain5
git switch -C codex/pr824-qkgain5 --track origin/codex/pr824-qkgain5
CUDA_VISIBLE_DEVICES=1 NPROC_PER_NODE=1 bash scripts/run_remote_experiment.sh pr824-qkgain5 experiments/pr824-qkgain5/train_gpt.py
```

### What not to do on the current 1xH100 pod

Do not run two real training jobs at once on the same single-GPU pod if you care about:

- fair speed comparisons
- stable memory behavior
- reproducible training curves

On a 1xH100 pod, the correct default is sequential GPU runs, not parallel GPU runs.

### What not to do for the 8xH100 submission stage

Do not:

- run two submission-stage experiments at once
- create multiple competing `8xH100` pods for the same comparison wave
- treat the submission stage as a high-throughput parallel search tier

The `8xH100` stage is intentionally serialized so results stay interpretable and cost stays bounded.

## SSH, logs, and model retrieval

To get current pod connection details after a start:

```bash
runpodctl pod get <pod_id>
```

For SSH, use the RunPod UI or the `pod get` output to find the current connection endpoint after the pod is running.

Inside the pod, all standardized remote runs now leave behind:

- log:
  - `logs/<RUN_ID>.txt`
- metadata:
  - `logs/<RUN_ID>.remote.meta.txt`
- summary:
  - `logs/<RUN_ID>.summary.txt`
- model artifacts:
  - `artifacts/<RUN_ID>/final_model.pt`
  - `artifacts/<RUN_ID>/final_model.int8.ptz`

Useful in-pod commands:

```bash
cd /workspace/parameter-golf
ls logs
ls artifacts
tail -n 80 logs/<RUN_ID>.txt
cat logs/<RUN_ID>.summary.txt
ls -lh artifacts/<RUN_ID>
```

If you need to preserve results before deleting a pod, copy out at least:

- `logs/<RUN_ID>.txt`
- `logs/<RUN_ID>.summary.txt`
- `artifacts/<RUN_ID>/final_model.int8.ptz`

If direct TCP SSH is enabled for the pod, you can use `scp` from the local machine once the pod is running. The exact host and port come from the RunPod connection panel for that pod.

Generic pattern:

```bash
scp -P <port> -i ~/.ssh/id_ed25519_personal \
  root@<host>:/workspace/parameter-golf/logs/<RUN_ID>.summary.txt \
  /tmp/<RUN_ID>.summary.txt

scp -P <port> -i ~/.ssh/id_ed25519_personal \
  root@<host>:/workspace/parameter-golf/artifacts/<RUN_ID>/final_model.int8.ptz \
  /tmp/<RUN_ID>.int8.ptz
```

## How to update repo memory after a remote run

Immediately update:

1. the experiment scratchpad
2. `codex_notes/coordination_live/experiment_board.md`
3. `codex_notes/coordination_live/remote_run_queue.md`

Copy only the high-signal facts:

- machine / provider
- run id
- log path
- artifact path
- pre-quant and post-quant metrics
- artifact size
- whether to continue or stop

Do not paste giant raw logs into notes.
