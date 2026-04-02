# Experiment

- Name: `kgiir-lite`
- Status: `IN_PROGRESS:main-agent`
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

- Currently running in `explore_lite_20260402`.
- Compare final post-quant BPB against fresh baseline `1.69239991` from `/Users/wulfie/code/parameter-golf/logs/explore_lite_20260402_baseline.txt`.
