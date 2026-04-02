# Experiment

- Name: `hyperconnection-lite`
- Status: `IN_PROGRESS:main-agent`
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

- Currently running in `explore_lite_20260402`.
- Compare final post-quant BPB against fresh baseline `1.69239991` from `/Users/wulfie/code/parameter-golf/logs/explore_lite_20260402_baseline.txt`.
