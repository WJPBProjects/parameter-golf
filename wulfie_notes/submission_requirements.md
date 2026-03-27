Parameter Golf submission requirements

Core constraints
- Artifact must be under 16,000,000 bytes total.
- Total counted artifact size = compressed model bytes + counted code bytes.
- Counted code should live in train_gpt.py.
- Artifact must be fully self-contained and reproducible.
- No external downloads, network calls, or training dataset access during evaluation.

Time limits
- Leaderboard-record submissions must train in under 10 minutes on 8xH100 SXM.
- Evaluation is separately capped at under 10 minutes on 8xH100.
- Reproducibility under the hardware/time cap is required for record submissions.

Scoring
- Primary score is val_bpb on the FineWeb validation set.
- The challenge is tokenizer-agnostic and evaluated in bits per byte.

Evaluation/training boundaries
- Do not access training data during evaluation unless those bits are paid for inside the 16MB artifact.
- Do not access validation data during training.
- Test-time training is only allowed on validation tokens that have already been evaluated.
- Evaluation methods can vary, including sequence length, as long as they stay within the rules.

Submission package contents
- Submit as a pull request that only adds a new folder under the appropriate records subfolder.
- Include a README.md explaining the submission in reasonable detail.
- Include a submission.json with author, GitHub ID, val_bpb, and related metadata.
- Include train log(s) produced by the script.
- Include a train_gpt.py script and any other needed dependencies.
- The script must compile and run successfully from inside the records folder.

Extra requirements for new SOTA record submissions
- Must beat the existing SOTA by at least 0.005 nats.
- Must provide enough run logs to show p < 0.01 significance for the claimed improvement.
- If the gain is purely a systems optimization without ML changes, the significance requirement is waived.
- If tokenizer or dataset changes are made, prove the val_bpb calculation is correct.

Non-record submissions
- Non-record submissions still need to satisfy the 16MB artifact limit.
- Unlimited-compute non-record submissions are accepted, but should be clearly labeled as such in the README.
- Non-record submissions should follow the same packaging format as record submissions.

Useful metadata fields commonly seen in submission.json
- author
- github_id
- name
- blurb
- date
- val_loss
- val_bpb
- pre_quant_val_loss
- pre_quant_val_bpb
- step_stop
- wallclock_seconds
- eval_time_seconds
- bytes_total
- bytes_model_int8_zlib
- bytes_code

Repo source references
- README.md lines 168-215
- README.md lines 217-223
- train_gpt.py final size logging around lines 1085-1092
