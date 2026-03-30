# PR824 Mimic Ablation 2026-03-27

Goal:

- understand why the local `PR824 mimic: XSA6 + GatedAttn + ValueResid` branch wins on the stronger local-screen harness

Shared baseline:

- `baseline_long_seed1337`
- post-quant `val_bpb: 2.15725007`

Full mimic:

- `pr824_mimic_long_seed1337`
- post-quant `val_bpb: 2.10420259`
- delta vs baseline: `-0.05304748`

## Ablations

| Variant | Run ID | Post-quant val_bpb | Delta vs baseline | Reading |
|---|---|---:|---:|---|
| `XSA6 only` | `pr824_ablation_xsa6_only` | `2.15776036` | `+0.00051029` | no real gain |
| `XSA6 + attn_gate` | `pr824_ablation_xsa6_attn_gate` | `2.14925218` | `-0.00799789` | modest gain |
| `XSA6 + value_residual` | `pr824_ablation_xsa6_value_residual` | `2.12640337` | `-0.03084670` | large gain |
| `XSA6 + attn_gate + value_residual` | `pr824_mimic_long_seed1337` | `2.10420259` | `-0.05304748` | best result |

## Interpretation

- `XSA6` is not the main reason the branch wins.
- `attn_gate` helps, but only modestly on its own.
- `value_residual` appears to be the dominant contributor.
- The full combo beats either component alone, so there is real composition rather than just one useful feature and one irrelevant feature.

## Working hypothesis

The local win is coming from two effects:

1. `value_residual` gives the stack a cheap extra pathway from `x0`, which seems to stabilize or enrich learning in a way the baseline residual/skip setup does not already capture.
2. `attn_gate` adds a smaller but real per-head control knob that composes with that stronger residual path.

If we want to mine the winning direction further, the next natural step is:

- isolate and refine `value_residual`
- then test whether `attn_gate` still helps on top of the best `value_residual` variant
