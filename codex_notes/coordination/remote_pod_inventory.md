# Remote Pod Inventory

This file tracks the current Parameter Golf RunPod fleet.

Use it with:

- `codex_notes/coordination_live/remote_experiment_playbook.md`
- `codex_notes/coordination_live/remote_run_queue.md`

## Fleet policy

- The `1xH100` validation fleet supports up to `3` concurrent remote validation runs.
- Those three validation lanes are Pods `A`, `B`, and `C` below.
- The true `8xH100` submission stage is single-lane only.
- Only `one` `8xH100` submission pod and one active submission-stage run should exist at a time unless the user explicitly overrides that policy.

## Current pods

### Pod A

- Role:
  - original reference pod
- RunPod name:
  - `comfortable_black_swordtail`
- Pod id:
  - `untjvs1cx2gq4u`
- Shape:
  - `1x NVIDIA H100 80GB HBM3`
- Image:
  - `runpod/parameter-golf:latest`
- Region:
  - `AP-IN-1`
- Storage:
  - container disk `50 GB`
  - volume disk `50 GB`
  - volume mount path `/workspace`
- Ports:
  - `8888/http`
  - `3000/http`
  - `22/tcp`
- Current intended use:
  - baseline or positive-control lane

### Pod B

- Role:
  - duplicate pod
- RunPod name:
  - `parameter-golf-h100-b`
- Pod id:
  - `2ollt57dzbud46`
- Shape:
  - `1x NVIDIA H100 80GB HBM3`
- Image:
  - `runpod/parameter-golf:latest`
- Region:
  - `AP-IN-1`
- Storage:
  - container disk `50 GB`
  - volume disk `50 GB`
  - volume mount path `/workspace`
- Ports:
  - `8888/http`
  - `3000/http`
  - `22/tcp`
- Current intended use:
  - promoted candidate lane

### Pod C

- Role:
  - duplicate pod
- RunPod name:
  - `parameter-golf-h100-c`
- Pod id:
  - `94x77u15s3v7s2`
- Shape:
  - `1x NVIDIA H100 80GB HBM3`
- Image:
  - `runpod/parameter-golf:latest`
- Region:
  - `AP-IN-1`
- Storage:
  - container disk `50 GB`
  - volume disk `50 GB`
  - volume mount path `/workspace`
- Ports:
  - `8888/http`
  - `3000/http`
  - `22/tcp`
- Current intended use:
  - promoted candidate lane

### Submission Pod

- Role:
  - single reserved true submission lane
- RunPod name:
  - `parameter-golf-8xh100-submission`
- Pod id:
  - `slc7ozmtif62ih`
- Shape:
  - `8x NVIDIA H100 80GB HBM3`
- Image:
  - `runpod/parameter-golf:latest`
- Region:
  - `CA`
- Storage:
  - container disk `50 GB`
  - volume disk `50 GB`
  - volume mount path `/workspace`
- Ports:
  - `8888/http`
  - `3000/http`
  - `22/tcp`
- Policy:
  - keep stopped unless a true stage-4 submission-style run is actively needed
  - do not run another submission pod in parallel

## Pod lifecycle commands

Important:

- `runpodctl pod list` shows running pods by default
- stopped pods may not appear in `pod list`
- use `runpodctl pod get <pod_id>` for a specific pod regardless of whether it is running

Start all three:

```bash
runpodctl pod start untjvs1cx2gq4u
runpodctl pod start 2ollt57dzbud46
runpodctl pod start 94x77u15s3v7s2
```

Start the submission pod only when needed:

```bash
runpodctl pod start slc7ozmtif62ih
```

Stop all three:

```bash
runpodctl pod stop untjvs1cx2gq4u
runpodctl pod stop 2ollt57dzbud46
runpodctl pod stop 94x77u15s3v7s2
```

Stop the submission pod immediately after the run and inspection:

```bash
runpodctl pod stop slc7ozmtif62ih
```

Inspect one pod:

```bash
runpodctl pod get untjvs1cx2gq4u
runpodctl pod get 2ollt57dzbud46
runpodctl pod get 94x77u15s3v7s2
runpodctl pod get slc7ozmtif62ih
```

## Suggested experiment assignment

Default three-way parallel layout:

- Pod A:
  - baseline
  - PR824 mimic positive control
  - `pr824-kgiir-lite`
- Pod B:
  - baseline
  - PR824 mimic positive control
  - `pr824-qkgain5`
- Pod C:
  - baseline
  - PR824 mimic positive control
  - `compile-safe-late-qat` or the next approved remote branch

This three-pod layout is the maximum intended normal parallelism for stage 3 remote validation.

## Session checklist

At the beginning of a remote session:

1. start only the pod(s) you need
2. run a same-pod baseline first
3. run the same-pod PR824 mimic positive control
4. run one promoted candidate per pod
5. collect logs and artifacts into notes
6. stop the pod when finished
