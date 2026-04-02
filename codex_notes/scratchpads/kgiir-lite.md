# Experiment

- Name: `kgiir-lite`
- Status: `TODO`
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

- Run it after the current exploit wave unless a stronger explore candidate displaces it.
