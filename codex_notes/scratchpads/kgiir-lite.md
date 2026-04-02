# Experiment

- Name: `kgiir-lite`
- Status: `PASS`
- Owner: `main-agent`
- Branch: `codex/kgiir-lite`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/kgiir-lite`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/kgiir-lite/train_gpt_mlx.py`

## Hypothesis

- A very small 4-tap identity-biased causal temporal mixer before the attention path may capture some of the trajectory-mixing signal from the architectural KGIIR direction without a big parameter or systems cost.

## Scope

- Local screen command(s):
  - `cd /Users/wulfie/code/parameter-golf-worktrees/kgiir-lite && TRAIN_MLX_SCRIPT=experiments/kgiir-lite/train_gpt_mlx.py bash scripts/run_local_confirm_mlx.sh`

## Next step

- Completed in `explore_lite_20260402`.
- Fresh wave baseline:
  - `/Users/wulfie/code/parameter-golf/logs/explore_lite_20260402_baseline.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.69239991`
- Result:
  - `/Users/wulfie/code/parameter-golf-worktrees/kgiir-lite/logs/explore_lite_20260402_kgiir_lite.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.67562160`
  - `delta vs fresh baseline: -0.01677831`
  - `step_avg: 318.83ms`
  - `serialized_model_int8_zlib: 15173162 bytes`
- Interpretation:
  - this is a strong local win for a lightweight temporal pre-attention mixer
  - the effect is weaker than `PR824 mimic` but clearly larger than `AttnRes-lite`
  - likely next branch: stack KGIIR-lite onto `PR824` or `value-residual-only` rather than continue this branch in isolation
