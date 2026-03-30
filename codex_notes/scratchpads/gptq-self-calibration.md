# Experiment Note

## Experiment

- Name: GPTQ self calibration
- Status: FAIL
- Owner: `worker-gptq-self-calibration`
- Branch: `codex/gptq-self-calibration`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/gptq-self-calibration`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/gptq-self-calibration/train_gpt_mlx.py`
  - `experiments/gptq-self-calibration/train_gpt.py` (left as baseline for now)

## Hypothesis

- Self-generated or synthetic calibration data may retain most post-quantization benefit while making the calibration path cheaper, less fragile, or easier to reproduce than a single fixed validation-only source.

## Scope

- Files expected to change:
  - `experiments/gptq-self-calibration/train_gpt_mlx.py`
  - `experiments/gptq-self-calibration/README.md`
- Local screen command(s):
  - `TEMP_SCALING=1 CALIBRATION_SOURCE=validation CALIBRATION_TOKENS=2048 SKIP_FINAL_INT8_EVAL=0 RUN_ID=gptq-self-calibration_validation ./.venv/bin/python experiments/gptq-self-calibration/train_gpt_mlx.py`
  - `TEMP_SCALING=1 CALIBRATION_SOURCE=self_generated CALIBRATION_TOKENS=2048 CALIBRATION_PROMPT_TOKENS=64 SKIP_FINAL_INT8_EVAL=0 RUN_ID=gptq-self-calibration_self_generated ./.venv/bin/python experiments/gptq-self-calibration/train_gpt_mlx.py`
  - `TEMP_SCALING=1 CALIBRATION_SOURCE=random_tokens CALIBRATION_TOKENS=2048 SKIP_FINAL_INT8_EVAL=0 RUN_ID=gptq-self-calibration_random_tokens ./.venv/bin/python experiments/gptq-self-calibration/train_gpt_mlx.py`
- Remote run command(s):
  - TBD after local screening

## Progress

- Baseline for comparison: `codex_notes/coordination/baseline_benchmarks.md`
- Prep complete for sequential local runs; no heavy training run executed in this branch yet.
- Sanity probe completed: `RUN_ID=gptq_self_calib_sanity` with `TEMP_SCALING=1 CALIBRATION_SOURCE=self_generated CALIBRATION_TOKENS=128 CALIBRATION_PROMPT_TOKENS=32 SKIP_FINAL_INT8_EVAL=0 DEV_VAL_MAX_BATCHES=1 ITERATIONS=0 WARMUP_STEPS=0 VAL_LOSS_EVERY=0 TRAIN_LOG_EVERY=0`.

## Local Screening

- Status: DONE
- Date:
- Log path:
- Artifact path(s):
- Throughput / wallclock:
- Val / BPB:
- Notes:
  - Added temperature-scaling support to the MLX trainer.
  - Added selectable calibration sources: `validation`, `self_generated`, `random_tokens`.
  - The self-generated path uses the model itself to greedily extend a short prompt from the training stream.
  - Sanity probe output: pre-quant `val_bpb:4.1027`, temp-scaled roundtrip `val_bpb:4.10922888`, chosen `temperature:0.90`.
  - `SKIP_FINAL_INT8_EVAL=0` is required if you want the final post-quant eval for comparison.
  - stronger local-screen reruns:
    - baseline on the same stronger harness: `2.15725007`
    - `validation`: `2.15908595` at temperature `0.95`
    - `self_generated`: `2.16323878` at temperature `0.90`
    - `random_tokens`: `2.17016297` at temperature `1.10`
    - conclusion: all three calibration-source variants lose to the baseline after the final quantized roundtrip

## Promotion Decision

- Promote to remote: HOLD
- Reason: The longer local-screen comparison says this family is not helping right now.
- Remote priority: medium

## Remote Training

- Status: TODO
- Date:
- Machine / provider:
- Run identifier:
- Log path:
- Artifact path(s):
- Pre-quant:
- Post-quant:
- Speed / wallclock:
- Artifact size:
- Notes:

## Results Summary

- Pre-quant:
- Post-quant:
- Speed / wallclock:
- Artifact size:

## Conclusion

- On the stronger default local-screen harness, this branch is a miss.
- The final quantized roundtrip metric got worse for all three calibration sources.

## Next step

- Keep this branch parked unless there is a new calibration idea that is materially different from the current three-source comparison.
