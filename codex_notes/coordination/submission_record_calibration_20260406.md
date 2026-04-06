# Submission Record Calibration 2026-04-06

Purpose:

- check whether the exact merged leaderboard record behaves sensibly on the true `8xH100` submission lane

Pod:

- `bg36rohzqz8svz`
- `parameter-golf-8xh100-calibration-1`

Script:

- `records/track_10min_16mb/2026-03-22_11L_EMA_GPTQ-lite_warmdown3500_QAT015_1.1233/train_gpt.py`

Claimed merged-record score:

- `1.1228`

Run id:

- `submission8x_merged_record_signalrush_20260406_180723`

Result:

- in-run validation:
  - `val_bpb: 1.1468`
- post-EMA diagnostic:
  - `val_bpb: 1.1462`
- final quantized exact:
  - `final_int6_roundtrip_exact val_bpb: 1.15421071`
- throughput:
  - `step_avg: 105.17ms`
- artifact size:
  - `Total submission size int6+zlib: 17054095 bytes`

Local result directory:

- `/Users/wulfie/code/parameter-golf/remote_results/20260406_180723_submission_record_signalrush`

Interpretation:

- the exact merged record is directionally correct on the true `8xH100` lane
- the earlier `1xH100` stage-3 proxy was the misleading part, not the basic repo or environment setup
- this confirms that leaderboard-relevant ranking decisions should be made on the real submission lane or on a proxy that has been explicitly recalibrated against it

Operational note:

- the wrapper hung after the final metric line
- the decisive log and both model artifacts were still written successfully
- outputs were pulled back manually
- the pod was stopped immediately afterward
