# Experiment

- Name: `hyperconnection-lite`
- Status: `FAIL`
- Owner: `main-agent`
- Branch: `codex/hyperconnection-lite`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/hyperconnection-lite`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/hyperconnection-lite/train_gpt_mlx.py`

## Hypothesis

- A tiny late-layer split-state residual router may capture some of the same value/residual-path benefits as the winning PR824 family while opening a broader residual-routing search direction.

## Scope

- Local screen command(s):
  - `cd /Users/wulfie/code/parameter-golf-worktrees/hyperconnection-lite && TRAIN_MLX_SCRIPT=experiments/hyperconnection-lite/train_gpt_mlx.py bash scripts/run_local_confirm_mlx.sh`

## Next step

- Result from `explore_lite_20260402`:
  - log: `/Users/wulfie/code/parameter-golf-worktrees/hyperconnection-lite/logs/explore_lite_20260402_hyperconnection_lite.txt`
  - `final_int8_zlib_roundtrip_exact val_bpb: 1.70267420`
  - fresh baseline: `1.69239991`
  - `step_avg: 301.77ms`
  - `serialized_model_int8_zlib: 15129316 bytes`
- Interpretation:
  - Clear local regression at this topology/init.
  - Drop this branch for now; if Hyper-Connections is revisited, it likely needs a different residual split or a PR824/value-path stack rather than this standalone form.
