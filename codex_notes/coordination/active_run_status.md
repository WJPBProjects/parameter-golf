# Active Run Status

Last updated: 2026-04-06 16:12 UTC

## Current execution

- Active wave: `IN_PROGRESS`
- Profile: `remote merged-record calibration`
- Current pod:
  - `yupx86fgiyv4ad`
  - `parameter-golf-validation-calibration-1`
- Current experiment:
  - bootstrap -> baseline -> exact merged record

## Why this run exists

- The previous remote shakedown proved the transport and artifact flow.
- It did not prove calibration, because the compared family was a partial public-PR mimic.
- The current run is meant to answer the narrower question:
  - does a merged, valid, near-top record look directionally strong on our remote stage-3 harness?

## Current control target

- `records/track_10min_16mb/2026-03-22_11L_EMA_GPTQ-lite_warmdown3500_QAT015_1.1233/train_gpt.py`
- claimed merged-record score:
  - `1.1228`

## Next actions after this run

1. pull back logs and artifacts
2. compare same-pod baseline versus merged-record control
3. if the control is directionally stronger, trust the remote harness more
4. then resume candidate validation on non-stale branches

## Billing rule

- no other pods should be left running unless they are actively serving the current batch
- stop the calibration pod immediately after the pullback completes
