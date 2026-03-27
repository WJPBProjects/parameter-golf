# AGENTS.md

This repo is intended to support iterative research by human and coding agents working
in parallel across separate experiment branches and worktrees.

## Purpose

- Keep experiments isolated.
- Preserve context between agent runs.
- Make it easy for future agents to understand what has already been tried.

## Repository note directories

### `wulfie_notes/`

- This directory contains user-authored notes and reference material.
- Treat everything in `wulfie_notes/` as **read-only** unless the user explicitly asks you to edit it.
- Use it as context, not as your scratchpad.

Current known files include:

- `wulfie_notes/TODO.md`
- `wulfie_notes/deep-research.md`
- `wulfie_notes/submission_requirements.md`

### `codex_notes/`

- This directory is the agent scratch space.
- Agents are encouraged to create and update notes here as they work.
- It is hierarchical by design:
  - `codex_notes/coordination/` for shared state like the experiment board
  - `codex_notes/planning/` for mutable planning notes
  - `codex_notes/templates/` for templates
  - `codex_notes/scratchpads/` for rough or experiment-specific notes
- Prefer small, focused Markdown files over one huge running log.
- The main coordination files are:
  - `codex_notes/coordination/experiment_board.md`
  - `codex_notes/coordination/baseline_benchmarks.md`
  - `codex_notes/coordination/promotion_rubric.md`
  - `codex_notes/templates/experiment_note_template.md`
- Good note topics:
  - experiment plans
  - branch/worktree ownership
  - commands used
  - results summaries
  - failed ideas worth not repeating
  - integration notes for future agents

Current seed file:

- `codex_notes/README.md`
- `codex_notes/coordination/experiment_board.md`
- `codex_notes/coordination/baseline_benchmarks.md`
- `codex_notes/coordination/promotion_rubric.md`
- `codex_notes/templates/experiment_note_template.md`

## Note-taking expectations for agents

- Before starting a new experiment, check `codex_notes/coordination/experiment_board.md`.
- Always reread the relevant note or board file immediately before editing it, so you do not overwrite newer context from another agent.
- This repo uses a two-stage experiment flow:
  - local screening first
  - remote promotion only for ideas that clear the local bar
- If you claim an experiment, update its local or remote status to `IN_PROGRESS:<agent_id>`.
- If your runtime does not expose an agent ID, use a stable owner label such as:
  - `IN_PROGRESS:main-agent`
  - `IN_PROGRESS:worker-xsa`
  - `IN_PROGRESS:worktree-xsa-all`
- Create or update a per-experiment note in `codex_notes/scratchpads/` using `codex_notes/templates/experiment_note_template.md`.
- Leave short factual notes when you do meaningful work.
- Prefer creating a new file when the topic is separate.
- Reuse an existing file when you are continuing the same experiment thread.
- Include concrete details:
  - branch name
  - worktree path
  - exact local-screen command(s)
  - exact remote-run command(s)
  - important metrics
  - log and artifact paths
  - what worked / failed
  - promotion decision
  - next step
- Keep notes concise and high signal.
- Do not dump giant raw logs into notes; summarize them and point to the log path instead.
- Record both:
  - whether the experiment has passed local screening
  - whether it should be promoted to remote training
- When a remote run is started or finished, update the board and the experiment note immediately so future agents can see:
  - which ideas still need remote runs
  - which ideas already ran remotely
  - which ideas are promising, weak, or dead ends
- If you stop mid-experiment, leave enough detail that another agent can resume without rereading the whole repo.

## Parallel experiment workflow

- Assume the user has already chosen or created the shared baseline unless they say otherwise.
- Use one branch per experiment.
- Use one git worktree per experiment.
- Give each coding agent a single worktree to own.
- Recombine ideas later by cherry-picking or merging proven winners into an integration branch.

See `PARALLEL_EXPERIMENTS.md` for the worktree workflow.

## Safety rules for agents

- Do not edit `wulfie_notes/` directly without explicit user instruction.
- Do not mix multiple unrelated experiments in one branch.
- Do not use `main` as an experiment scratch branch.
- Do not put experiment-priority decisions or first-wave plans into `PARALLEL_EXPERIMENTS.md`; keep those in `codex_notes/`.
- When in doubt, write a note in `codex_notes/` before or after significant work so future agents can pick up context quickly.
