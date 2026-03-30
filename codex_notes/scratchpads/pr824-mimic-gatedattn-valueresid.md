# Experiment Note

## Experiment

- Name: PR824 mimic: XSA6 + GatedAttn + ValueResid
- Status: PASS
- Owner: `main-agent`
- Branch: `codex/pr824-mimic-gatedattn-valueresid`
- Worktree: `/Users/wulfie/code/parameter-golf-worktrees/pr824-mimic-gatedattn-valueresid`
- Seed(s): `1337`
- Experiment-local trainer path(s):
  - `experiments/pr824-mimic-gatedattn-valueresid/train_gpt.py`
  - `experiments/pr824-mimic-gatedattn-valueresid/train_gpt_mlx.py`

## Hypothesis

- If the local screening stack is meaningful, a partial mimic of the strongest current transformer-style PR should move the metric in the same direction as the online result.

## Scope

- Files changed:
  - `experiments/pr824-mimic-gatedattn-valueresid/train_gpt.py`
  - `experiments/pr824-mimic-gatedattn-valueresid/train_gpt_mlx.py`
  - `experiments/pr824-mimic-gatedattn-valueresid/README.md`
- Local screen command(s):
  - `RUN_ID=pr824_mimic_local_screen TRAIN_MLX_SCRIPT=experiments/pr824-mimic-gatedattn-valueresid/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh`
- Remote run command(s):
  - TBD; this is a partial PR mimic, not yet a full remote candidate stack

## Progress

- Online source anchor:
  - `PR #824` = `GatedAttn + ValueResid + XSA6 + HedgeMixer + Legal TTT`
- Local approximation used here:
  - start from the local `xsa-all` trainer copy
  - default `XSA_LAST_N=6`
  - add per-head `attn_gate`
  - add per-block scalar `lambda_v`
  - keep both in FP32 / out of GPTQ via `CONTROL_TENSOR_NAME_PATTERNS`
- Deliberately excluded:
  - `HedgeMixer`
  - `BigramHash4K`
  - legal TTT

## Local Screening

- Status: PASS
- Date: `2026-03-27`
- Log path:
  - `logs/pr824_mimic_local_screen.txt`
- Artifact path(s):
  - `logs/pr824_mimic_local_screen_mlx_model.npz`
  - `logs/pr824_mimic_local_screen_mlx_model.int8.ptz`
- Throughput / wallclock:
  - baseline screen: `277.01ms/step`
  - mimic: `291.44ms/step`
- Val / BPB:
  - baseline screen: `2.2674`
  - mimic: `2.2407`
- Artifact size:
  - baseline screen: `12,291,845 bytes`
  - mimic: `12,496,386 bytes`
- Notes:
  - This is a direct apples-to-apples comparison against the shared `local_screen` harness.
  - The mimic is slower and slightly larger, but clearly better on validation BPB.
  - Delta vs baseline: `-0.0267 val_bpb`, `+14.43ms/step`, `+204,541 bytes`.
  - Rerun on the stronger default local-screen harness:
    - command: `SEED=1337 RUN_ID=pr824_mimic_long_seed1337 TRAIN_MLX_SCRIPT=experiments/pr824-mimic-gatedattn-valueresid/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh`
    - baseline on the same stronger harness: `2.15725007`
    - mimic on the stronger harness: `2.10420259`
    - artifact size: `13,926,887 bytes`
    - delta vs baseline: `-0.05305 val_bpb`, `-1.87ms/step`, `+190,651 bytes`
  - component ablations on the same stronger harness:
    - `XSA6 only`:
      - command: `ATTN_GATE_ENABLE=0 VALUE_RESIDUAL_ENABLE=0 ...`
      - post-quant `val_bpb:2.15776036`
      - delta vs baseline: `+0.00051029`
    - `XSA6 + attn_gate`:
      - command: `ATTN_GATE_ENABLE=1 VALUE_RESIDUAL_ENABLE=0 ...`
      - post-quant `val_bpb:2.14925218`
      - delta vs baseline: `-0.00799789`
    - `XSA6 + value_residual`:
      - command: `ATTN_GATE_ENABLE=0 VALUE_RESIDUAL_ENABLE=1 ...`
      - post-quant `val_bpb:2.12640337`
      - delta vs baseline: `-0.03084670`
    - interpretation:
      - `XSA6` itself is not the source of the gain
      - `attn_gate` helps somewhat
      - `value_residual` appears to be the larger contributor
      - the full combination still beats either ablation, so the two components compose

## Promotion Decision

- Promote to remote: READY
- Reason:
  - The local harness gave the expected direction of improvement on a current leaderboard-inspired change.
  - That means the local stack is informative enough to use for screening.
- Remote priority: medium-high

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

## Conclusion

- The local stack is not useless. It produced a real positive signal on a top-PR-inspired architectural change.
- This was only a partial mimic, so the result is still directional rather than conclusive.
- But on the stronger longer-harness rerun, the improvement got larger rather than disappearing, which makes this one of the clearest current local winners.
- Based on ablations, the win seems to come mostly from `value_residual`, with an additional smaller gain from `attn_gate`.

## Next step

- Use the same `local_screen` harness for the next screening wave.
- If we want a closer reproduction of `#824`, add the missing stack pieces in separate isolated experiments rather than folding them into this branch all at once.
