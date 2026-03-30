# Local Rerun Wave 2026-03-27

This file records the apples-to-apples local rerun wave after `run_local_screen_mlx.sh` was strengthened to:

- `ITERATIONS=800`
- `DEV_VAL_MAX_BATCHES=256`
- `SKIP_FINAL_INT8_EVAL=0`

Shared baseline:

- run id: `baseline_long_seed1337`
- post-quant `val_bpb`: `2.15725007`
- step avg: `282.46ms`
- artifact size: `13,736,236 bytes`

## Results

| Experiment | Run ID | Post-quant val_bpb | Delta vs baseline | Step avg | Artifact size | Verdict |
|---|---|---:|---:|---:|---:|---|
| Baseline | `baseline_long_seed1337` | `2.15725007` | `0.00000000` | `282.46ms` | `13,736,236` | reference |
| XSA all layers | `xsa_all_long_seed1337_v2` | `2.15552024` | `-0.00172983` | `281.78ms` | `13,743,183` | tiny positive, not enough margin |
| PR824 mimic: XSA6 + GatedAttn + ValueResid | `pr824_mimic_long_seed1337` | `2.10420259` | `-0.05304748` | `280.59ms` | `13,926,887` | clear winner |
| LeakyReLU slope `0.05` | `leakyrelu_long_seed1337` | `2.15780121` | `+0.00055114` | `275.89ms` | `13,726,672` | effectively flat / slightly worse |
| Selective post-GPTQ pruning | `selective_post_gptq_pruning_long_seed1337` | `2.16040061` | `+0.00315054` | `277.59ms` | `13,533,627` | loses quality, helps size |
| GPTQ self calibration: validation | `gptq_self_calibration_validation_long_seed1337` | `2.15908595` | `+0.00183588` | `276.90ms` | `13,727,786` | slight regression |
| GPTQ self calibration: self_generated | `gptq_self_calibration_self_generated_long_seed1337` | `2.16323878` | `+0.00598871` | `282.37ms` | `13,733,874` | regression |
| GPTQ self calibration: random_tokens | `gptq_self_calibration_random_tokens_long_seed1337` | `2.17016297` | `+0.01291290` | `278.03ms` | `13,734,402` | clear regression |
| RoPE + LN-scale (`ROPE_DIM=16`, `LN_SCALE_INIT=inv_sqrt`) | `rope_lnscale_grid_long_seed1337` | `2.17965799` | `+0.02240792` | `279.16ms` | `13,510,116` | clear regression |
| SplineConv hybrid | `splineconv_hybrid_long_seed1337` | `2.15680018` | `-0.00044989` | `290.69ms` | `13,783,464` | basically neutral |

## Interpretation

- The stronger local-screen harness is useful enough to separate a clear local winner from the rest.
- The best branch in this wave is the partial PR824 mimic.
- Most of the other ideas either regressed or moved by too little to justify remote spend.

## Best next remote candidates

1. `PR824 mimic: XSA6 + GatedAttn + ValueResid`
2. `XSA all layers` only if we want to test a very small-margin candidate

Everything else should stay local-only or be deprioritized for now.
