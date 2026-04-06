# Remote Pod Inventory

This file tracks the active remote fleet for this repo.

## Fleet policy

- The `1xH100` validation fleet has been retired.
- The primary ranking lane is now the true `8xH100` submission fleet.
- Current budget policy is to run `1` warm `8xH100` pod at a time.
- Keep all pods stopped unless they are actively serving the current batch.

## Current `8xH100` fleet

### Pod A

- RunPod name:
  - `parameter-golf-8xh100-calibration-1`
- Pod id:
  - `bg36rohzqz8svz`
- Shape:
  - `8x NVIDIA H100 80GB HBM3`
- State intent:
  - stopped until claimed

### Pod C

- RunPod name:
  - `parameter-golf-8xh100-calibration-3`
- Pod id:
  - `h91bgyz08fp9dk`
- Shape:
  - `8x NVIDIA H100 80GB HBM3`
- State intent:
  - stopped until claimed

## Deleted fleet

These pods were intentionally removed and should no longer be used:

- `yupx86fgiyv4ad`
- `untjvs1cx2gq4u`
- `2ollt57dzbud46`
- `94x77u15s3v7s2`
- `slc7ozmtif62ih`
- `p0q5f3wenzygvr`

## Lifecycle commands

Check live state:

```bash
runpodctl pod list --output=json
runpodctl pod get bg36rohzqz8svz --output=json
runpodctl pod get h91bgyz08fp9dk --output=json
```

Automatic claim:

```bash
bash scripts/claim_remote_submission_pod.sh main-agent
```

Automatic release:

```bash
bash scripts/release_remote_submission_pod.sh bg36rohzqz8svz
```

## Batch assignment model

During a budget-constrained run:

- Pod A:
  - primary live queue
- Pod C:
  - fallback if Pod A is unavailable or after queue A succeeds and budget remains

Queue B and queue C are overflow queues. They are not a default instruction to run multiple live pods in parallel.
