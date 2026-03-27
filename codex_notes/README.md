# codex_notes

This directory is shared agent memory and scratch space.

Important:

- `codex_notes/coordination_live/` is the canonical shared coordination path when present.
- In experiment worktrees, `coordination_live/` points back to the main worktree so board/status updates stay shared.
- `codex_notes/scratchpads/` remains branch-local by design.

Structure:

- `coordination/`
  - shared experiment board and other high-priority coordination files
- `planning/`
  - mutable planning notes such as likely first-wave experiment ideas
- `templates/`
  - note templates for experiments and handoff docs
- `scratchpads/`
  - ad hoc notes, rough thinking, temporary agent notes

Agents should start with:

1. `coordination_live/experiment_board.md`
2. `coordination_live/baseline_benchmarks.md`
3. `coordination_live/promotion_rubric.md`
4. `templates/experiment_note_template.md`

The intended flow is:

1. claim or inspect an experiment on the board
2. run local screening first
3. mark whether the experiment should be promoted to remote training
4. record remote-run outcomes in the same experiment note

Then create or update a specific experiment note or scratchpad as needed.
