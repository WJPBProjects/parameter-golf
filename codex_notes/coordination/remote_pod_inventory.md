# Remote Pod Inventory

This file tracks the current RunPod fleet that is relevant to this repo.

## Fleet policy

- Stage 3 validation:
  - up to `3` parallel `1xH100` pods
- Stage 4 submission:
  - exactly one `8xH100` lane
- Do not leave idle pods running.

## Current known pods

### Active calibration pod

- RunPod name:
  - `parameter-golf-validation-calibration-1`
- Pod id:
  - `yupx86fgiyv4ad`
- Shape:
  - `1x NVIDIA H100 80GB HBM3`
- Image:
  - `runpod/parameter-golf:latest`
- Current use:
  - same-pod baseline + exact merged-record calibration run

### Submission pod

- Pod id:
  - `slc7ozmtif62ih`
- Intended use:
  - true `8xH100` submission-style run only
- Policy:
  - keep stopped unless explicitly needed

## Important note

The older A/B/C validation inventory is no longer authoritative.

Do not assume those pod ids still exist. Check live state first with:

```bash
runpodctl pod list --output=json
runpodctl pod get <pod-id> --output=json
runpodctl ssh info <pod-id>
```

## Lifecycle rule

For an active batch:

1. start or create only the pod(s) you need
2. run baseline first
3. run the exact merged-record control
4. run the promoted candidate(s)
5. pull back logs and artifacts after each run
6. stop the pod when the batch is done

## Suggested assignment

When multiple validation pods exist:

- Pod 1:
  - baseline
  - exact merged-record control
  - candidate A
- Pod 2:
  - baseline
  - exact merged-record control
  - candidate B
- Pod 3:
  - baseline
  - exact merged-record control
  - candidate C
