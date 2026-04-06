# Remote Pod Inventory

This file tracks the active remote fleet for this repo.

## Fleet policy

- The `1xH100` validation fleet has been retired.
- The primary ranking lane is now a `3`-pod `8xH100` fleet.
- Keep all pods stopped unless they are actively serving a batch.

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

### Pod B

- RunPod name:
  - `parameter-golf-8xh100-calibration-2`
- Pod id:
  - `p0q5f3wenzygvr`
- Shape:
  - `8x NVIDIA H100 80GB HBM3`
- State intent:
  - stopped until claimed
  - deprioritized after two `Exited by RunPod` events during setup on `2026-04-06`

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

## Lifecycle commands

Check live state:

```bash
runpodctl pod list --output=json
runpodctl pod get bg36rohzqz8svz --output=json
runpodctl pod get p0q5f3wenzygvr --output=json
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

During a real run:

- Pod A:
  - candidate batch A
- Pod B:
  - candidate batch B
- Pod C:
  - candidate batch C

Each pod should stay warm for its own sequential batch, then be stopped immediately.
