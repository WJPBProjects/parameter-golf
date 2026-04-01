# Local-Only Iteration Strategy (2026-04-01)

This note is for the current reality: local MLX only, no remote judge yet.

## Goal

Use the Mac as a serious filter, not the final truth source:

1. rerun the old wave on the current machine
2. verify the local harness still produces directionally consistent results
3. focus the next wave around the best-performing family
4. refresh the public PR frontier between waves

## Operating assumptions

- Local MLX is good enough to reject bad ideas and confirm obvious wins.
- Local MLX is not enough to settle CUDA-only or systems-heavy ideas.
- The strongest known local positive control is the PR824 mimic family.
- If the PR824 family stops winning locally, re-check the harness before trusting any new local ranking.

## Standard loop

### Phase 1: Rebaseline and rerun

1. Restore experiment worktrees:
   - `bash scripts/restore_experiment_worktrees.sh`
2. Re-run the full local wave on the current machine:
   - `bash scripts/run_local_wave.sh rerun-all confirm`
   - for unattended runs: `CONTINUE_ON_ERROR=1 bash scripts/run_local_wave.sh rerun-all confirm`
3. Compare every result against:
   - `baseline_long_new_laptop`
4. Update:
   - `codex_notes/coordination/experiment_board.md`
   - relevant scratchpads
   - `baseline_benchmarks.md` if the machine-level baseline changes

### Phase 2: Focus on the winning family

If the rerun-all wave still says the PR824 mimic family wins:

1. treat `value_residual` as the main driver
2. treat `attn_gate` as a likely stackable secondary effect
3. run the narrower overnight wave:
   - `bash scripts/run_local_wave.sh winner-focus overnight`
   - for unattended runs: `CONTINUE_ON_ERROR=1 bash scripts/run_local_wave.sh winner-focus overnight`
4. if the winner still holds, branch nearby rather than brainstorming far away

## What to mutate next if PR824-style changes still win

Priority order:

1. `value_residual` variants
   - narrower or broader layer coverage
   - different initialization strength
   - alternate injection points
2. `attn_gate` variants
   - init bias
   - all layers vs selected layers
   - interaction with value residual
3. hash-memory and value-path additions from newer public PRs
   - `EngramLite`
   - larger `BigramHash`
   - `TrigramHash`

## What not to prioritize locally

- CUDA-only compile/QAT questions
- FlashAttention / fused kernel work
- final GPTQ quality claims
- any idea whose main value is “processes more tokens on H100 in 10 minutes”

## Between-wave research tasks

After each completed wave:

1. review the current public frontier again
2. read the newest strong PRs in detail, not just their summaries
3. extract one or two concrete deltas from a winning PR
4. port or mimic those deltas locally
5. only then spend time on more original ideas

## Dataset reminder

The local 10-shard subset is fine for fast screening. For longer overnight runs, strongly consider:

- `TRAIN_SHARDS=50 bash scripts/prepare_local_extended_data.sh`

That reduces the chance that longer local runs are mostly measuring early repetition on a tiny subset.

## Simple decision rule

- clear win locally:
  - keep pushing the family
- tiny win locally:
  - rerun longer before believing it
- local loss:
  - drop it unless the idea is obviously remote/system-specific
