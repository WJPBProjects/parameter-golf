# codex_notes

This directory is shared agent memory and scratch space.

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

1. `coordination/experiment_board.md`
2. `coordination/baseline_benchmarks.md`
3. `coordination/promotion_rubric.md`
4. `templates/experiment_note_template.md`

The intended flow is:

1. claim or inspect an experiment on the board
2. run local screening first
3. mark whether the experiment should be promoted to remote training
4. record remote-run outcomes in the same experiment note

Then create or update a specific experiment note or scratchpad as needed.
