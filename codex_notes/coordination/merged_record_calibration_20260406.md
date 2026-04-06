# Merged Record Calibration 2026-04-06

Purpose:

- test whether the remote stage-3 `1xH100` harness produces directional signal for an exact merged leaderboard record

Pod:

- `yupx86fgiyv4ad`
- `parameter-golf-validation-calibration-1`

Run order:

1. baseline on `main`
2. exact merged record on `main`

Baseline:

- Run id:
  - `remote_merged_record_baseline_20260406_171426`
- Script:
  - `train_gpt.py`
- Result:
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.32581447`
  - `step_avg: 418.21ms`
  - `Total submission size int8+zlib: 13820769 bytes`

Merged record control:

- Run id:
  - `remote_merged_record_signalrush_20260406_171426`
- Script:
  - `records/track_10min_16mb/2026-03-22_11L_EMA_GPTQ-lite_warmdown3500_QAT015_1.1233/train_gpt.py`
- Claimed merged-record score:
  - `1.1228`
- Same-pod remote result here:
  - `final_int6_roundtrip_exact val_bpb: 2.32295979`
  - `step_avg: 665.24ms`
  - `Total submission size int6+zlib: 7741801 bytes`

Operational note:

- the trainer finished writing the decisive metric and both artifacts
- the wrapper hung after logging, so cleanup was manual
- local copies were pulled back manually into:
  - `/Users/wulfie/code/parameter-golf/remote_results/20260406_171426_merged_record_signalrush`

Interpretation:

- this remote stage-3 `1xH100` harness is not yet calibrated enough to trust for leaderboard-direction ranking
- the mismatch is too large to treat as ordinary seed or hardware noise
- next remote work should focus on debugging calibration, not candidate fishing
