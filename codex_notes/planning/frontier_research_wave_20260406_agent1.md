# Frontier Research Wave

Date: `2026-04-06`

## Scope

This note summarizes the current public `parameter-golf` frontier from merged leaderboard records and recent open PRs, with an eye toward ideas that are still worth porting into new experiments.

## Top mechanisms that look real on the legal submission lane

1. `SLOT` / score-first adaptation
   - Strongest current public signal is the `SLOT` family, especially scored-position variants and score-first TTT.
   - Relevant refs:
     - [PR #1229](https://github.com/openai/parameter-golf/pull/1229)
     - [PR #1209](https://github.com/openai/parameter-golf/pull/1209)
     - [PR #1217](https://github.com/openai/parameter-golf/pull/1217)

2. `GPTQ` plus stronger calibration / adaptation before quantization
   - The frontier is no longer just "quantize better"; it is "adapt before quantization, then quantize cleanly".
   - Relevant refs:
     - [PR #1364](https://github.com/openai/parameter-golf/pull/1364)
     - [PR #1209](https://github.com/openai/parameter-golf/pull/1209)
     - [PR #1361](https://github.com/openai/parameter-golf/pull/1361)

3. Value-path additions
   - Value residual, value embedding, and embedding skip / second-input embedding remain the most transferable architecture family from the small-model literature.
   - Relevant public signals:
     - [PR #1361](https://github.com/openai/parameter-golf/pull/1361)
     - [PR #1229](https://github.com/openai/parameter-golf/pull/1229)
   - This matches our local result that the value-residual path was the main winning ingredient.

4. Geometry / stabilization knobs
   - `QK_GAIN`, partial RoPE, LN-scale, zero-init style projection changes, and similar stabilization tweaks still show up repeatedly in the winning stacks.
   - Relevant refs:
     - [PR #1217](https://github.com/openai/parameter-golf/pull/1217)
     - [PR #1364](https://github.com/openai/parameter-golf/pull/1364)
     - [PR #1361](https://github.com/openai/parameter-golf/pull/1361)

5. Residual topology changes
   - Parallel residual lanes and lightweight recurrence still look like real contributors when they are part of a broader legal stack.
   - Relevant refs:
     - [PR #1204](https://github.com/openai/parameter-golf/pull/1204)
     - [PR #1370](https://github.com/openai/parameter-golf/pull/1370)

## Probably duplicated or already exhausted here

- `PR824`-style value residual + gating + XSA family
  - already explored locally and remotely in several forms
  - likely exhausted as a standalone lane

- Standalone `QK_GAIN=5.0`
  - already tested locally; the effect was real only when stacked with stronger branches

- Plain `XSA-all`
  - already tested locally and remotely in multiple variants

- Plain `ParallelResiduals`
  - already tested locally and remotely

- `KGIIR-lite`
  - already explored locally and stacked with PR824-like branches

- `1xH100` proxy calibration as a ranking lane
  - now known to be misleading for this repo

## Three novel combination candidates not yet run locally/remotely

1. `late-value-embed-qk5`
   - `value embedding` + `QK_GAIN_INIT=5.0` + late-layer reinjection
   - This is the cleanest current candidate because it combines the strongest local mechanism with the strongest external stabilizer signal.

2. `value embedding + pre-quant AdamW TTT`
   - Combine a value-path branch with the pre-quant adaptation idea from [PR #1364](https://github.com/openai/parameter-golf/pull/1364).
   - Good if the value-path improvement is mostly an optimization-shaping effect rather than a pure architecture effect.

3. `value embedding + SLOT / score-first TTT`
   - Use the value-path branch as the base, then add a legal SLOT or score-first adaptation path modeled after [PR #1209](https://github.com/openai/parameter-golf/pull/1209) and [PR #1229](https://github.com/openai/parameter-golf/pull/1229).
   - This is higher-risk because SLOT is eval-heavy, but it is the most direct way to test whether the new value path composes with the current frontier.

## Working conclusion

- The best public lane is now a three-way stack:
  - `SLOT` / score-first adaptation
  - `GPTQ` with better calibration or pre-quant adaptation
  - value-path / residual-path changes
- The best next internal move is to keep exploiting the value-path family while testing whether it composes with the new frontier stack rather than re-running the already-exhausted PR824 lane.
