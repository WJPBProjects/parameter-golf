# Parallel Experiment Workflow

This repo is a good fit for parallel experiment branches, but only if each experiment
gets its own git worktree and branch.

## Why

- Separate experiments should not share a write path.
- ML runs produce logs, checkpoints, and code edits that are easier to compare when isolated.
- Codex workers can safely operate in parallel if each worker owns one worktree.

## Recommended structure

- Shared baseline branch: `main` or a dedicated integration branch.
- One experiment per branch: `codex/<experiment-name>`.
- One experiment per worktree, created as a sibling directory:
  - `../parameter-golf-worktrees/<experiment-name>`

## Current state

- `main` currently contains the committed exploration/planning baseline.
- This repo also has:
  - `wulfie_notes/` for user-authored, read-only notes
  - `codex_notes/` for agent scratch notes and memory
- Agents should read `AGENTS.md` before writing notes or starting parallel work.
- In the normal flow, agents should assume a shared baseline already exists and branch off from it.

## Interference review

With separate worktrees, code edits and default training outputs are isolated well:

- `train_gpt.py` writes `final_model.pt` and `final_model.int8.ptz` into the current working directory.
- `train_gpt.py` writes logs into `logs/<RUN_ID>.txt`.
- `train_gpt_mlx.py` writes outputs into `OUT_DIR` (default `logs/`) under the current working directory.

That means separate worktrees do not clobber each other's model artifacts by default.

The remaining shared-resource issue is setup, not code interference:

- fresh worktrees need access to the shared Python environment
- fresh worktrees need access to the downloaded dataset/tokenizers
- fresh worktrees should see the shared `codex_notes/` board

The helper script handles this by linking shared local resources into each new worktree.

## Important prerequisite

If the current main worktree has uncommitted changes that you want every experiment to inherit,
commit them first, or create experiments from a branch/commit that already contains them.

Worktrees created from `HEAD` do not automatically include uncommitted local edits.

## Create a new experiment

```bash
bash scripts/create_experiment_worktree.sh xsa-all
bash scripts/create_experiment_worktree.sh gptq-self-calibration
bash scripts/create_experiment_worktree.sh splineconv-hybrid
```

You can also specify a base ref:

```bash
bash scripts/create_experiment_worktree.sh xsa-all codex/integration-baseline
```

## Remove an experiment

```bash
bash scripts/remove_experiment_worktree.sh xsa-all
```

## Recommended Codex workflow

1. Start from the existing shared baseline branch or commit provided by the user.
2. Create one worktree per experiment.
3. Give each Codex worker a single worktree path and clear file ownership.
4. Run the experiment locally first and capture:
   - exact code changes
   - exact local command
   - exact local logs
   - local metrics
5. Mark whether the experiment should be promoted to remote training on the board.
6. If promoted, run the remote job and capture:
   - exact remote command
   - remote log path / run identifier
   - pre-quant and post-quant metrics
   - artifact size
7. Commit each experiment independently on its own branch.
8. Compare winners and cherry-pick or merge only the promising ones into an integration branch.

## Notes and memory

- Read user context from `wulfie_notes/`, but do not edit it unless explicitly asked.
- Leave agent notes in `codex_notes/`.
- When an experiment starts, it is a good idea to create a note file such as:
  - `codex_notes/scratchpads/xsa-all.md`
  - `codex_notes/scratchpads/gptq-self-calibration.md`
- Reread the relevant coordination or scratchpad file immediately before editing it.
- At minimum, record:
  - branch/worktree
  - local commands run
  - remote commands run
  - log and artifact paths
  - metrics observed
  - whether the experiment should be promoted to remote
  - current conclusion

## What not to do

- Do not run multiple experiments in the same worktree.
- Do not let multiple workers edit the same branch.
- Do not treat uncommitted local edits in `main` as if they were part of the shared baseline.
- Do not treat this file as the source of truth for which experiments should be run first; put experiment-specific planning in `codex_notes/`.

## Notes on hardware

- For local MLX runs, do not assume many experiments can train concurrently on one machine.
- The branching/worktree setup enables safe parallel development and logging.
- Actual parallel training capacity depends on available GPU / Metal / CUDA resources.
