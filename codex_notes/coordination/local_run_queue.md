# Local Run Queue

Use this file as the current local-only runbook.

The important current baseline reference is:

- `codex_notes/coordination/baseline_benchmarks.md`
- New-laptop longer local-screen baseline:
  - `baseline_long_new_laptop`
  - post-quant `val_bpb: 2.15602005`
  - `step_avg: 269.78ms`

## Fresh machine bootstrap

If the repo has notes but not the old experiment worktrees, restore them first:

```bash
cd /Users/wulfie/code/parameter-golf
bash scripts/restore_experiment_worktrees.sh
```

For longer local runs, the current tiers are:

- `scripts/run_local_screen_mlx.sh`
- `scripts/run_local_confirm_mlx.sh`
- `scripts/run_local_overnight_mlx.sh`

`confirm` is now the default serious local comparison tier. `overnight` is for the narrow winner-focused wave.

## Whole-wave commands

Rerun the full historical local wave on the current machine:

```bash
cd /Users/wulfie/code/parameter-golf
bash scripts/run_local_wave.sh rerun-all confirm
```

If this is an unattended overnight pass and you want the queue to keep going even if one experiment fails:

```bash
cd /Users/wulfie/code/parameter-golf
CONTINUE_ON_ERROR=1 bash scripts/run_local_wave.sh rerun-all confirm
```

Once the rerun-all wave is finished, use the narrower overnight wave:

```bash
cd /Users/wulfie/code/parameter-golf
bash scripts/run_local_wave.sh winner-focus overnight
```

The runner writes a simple wave-level progress log to:

- `logs/<RUN_TAG>_wave.txt`

## Latest-PR signal check

After the historical rerun wave, use this to validate that the current public frontier still moves in the right direction locally:

```bash
cd /Users/wulfie/code/parameter-golf
CONTINUE_ON_ERROR=1 bash scripts/run_local_wave.sh latest-pr-signal confirm
```

That wave currently runs:

1. baseline
2. `PR824` mimic positive control
3. `QK_GAIN=5.0` (`PR1217`-inspired)
4. parallel residuals partial port (`PR1204`-inspired)

## PR824 exploit wave

After the latest-PR signal wave and the partial `PR1218` run, the next exploit-focused batch is:

```bash
cd /Users/wulfie/code/parameter-golf
CONTINUE_ON_ERROR=1 bash scripts/run_local_wave.sh pr824-exploit confirm
```

That wave runs:

1. baseline
2. `PR824` mimic
3. `PR824` value-residual-only
4. `PR824` attn-gate-only
5. `PR824 + QK_GAIN=5.0`
6. `PR824` with `XSA_LAST_N=4`

## Explore-lite wave

After the exploit wave, use this small literature-backed explore batch:

```bash
cd /Users/wulfie/code/parameter-golf
CONTINUE_ON_ERROR=1 bash scripts/run_local_wave.sh explore-lite confirm
```

That wave runs:

1. baseline
2. `attnres-lite`
3. `hyperconnection-lite`
4. `kgiir-lite`

## Next-frontier-lite wave

Once `pr824-exploit` and `explore-lite` complete, the next prepared queue is:

```bash
cd /Users/wulfie/code/parameter-golf
CONTINUE_ON_ERROR=1 bash scripts/run_local_wave.sh next-frontier-lite confirm
```

That wave should run:

1. baseline
2. `PR824 + value-embedding-lite`
3. `PR824 + ParallelResiduals`
4. `MoHD last-MLP lite`

## PR824 fixups wave

`pr824-qkgain5` and `pr824-xsa4` were repaired after their first `pr824-exploit` attempts were manually stopped because the branch configs were wrong.

Run this wave after `next-frontier-lite`:

```bash
cd /Users/wulfie/code/parameter-golf
CONTINUE_ON_ERROR=1 bash scripts/run_local_wave.sh pr824-fixups confirm
```

That wave runs:

1. baseline
2. `PR824` mimic
3. repaired `PR824 + QK_GAIN=5.0`
4. repaired `PR824` with `XSA_LAST_N=4`

## PR824 stacks wave

After `pr824-fixups`, run the prepared composite branches that stack the current best PR824 core with the two strongest explore wins:

```bash
cd /Users/wulfie/code/parameter-golf
CONTINUE_ON_ERROR=1 bash scripts/run_local_wave.sh pr824-stacks confirm
```

That wave runs:

1. baseline
2. `PR824` mimic
3. `PR824 + KGIIR-lite`
4. `PR824 + AttnRes-lite`

## PR824 explore2 wave

After `pr824-stacks`, run the two lighter attention-side PR824 variants from the frontier refresh:

```bash
cd /Users/wulfie/code/parameter-golf
CONTINUE_ON_ERROR=1 bash scripts/run_local_wave.sh pr824-explore2 confirm
```

That wave runs:

1. baseline
2. `PR824` mimic
3. `PR824` no XSA
4. `PR824` value residual init `0.20`
5. `PR824 + soft XSA`
6. `PR824 + DiffAttn-lite`

## Value-embedding retry wave

The first `PR824 + value-embedding-lite` attempt trained to pre-quant `val_bpb: 1.6884` but failed during `mx.savez` because of non-array Python metadata in `model.state`. The branch-local bug is fixed, so run a clean retry after `pr824-explore2`:

```bash
cd /Users/wulfie/code/parameter-golf
CONTINUE_ON_ERROR=1 bash scripts/run_local_wave.sh value-embedding-retry confirm
```

## Dataset note for longer local runs

The current laptop setup uses `10` train shards. That is fine for quick screening, but for longer local-only runs it is reasonable to expand the local subset first:

```bash
cd /Users/wulfie/code/parameter-golf
TRAIN_SHARDS=50 bash scripts/prepare_local_extended_data.sh
```

Do this before trusting very long overnight comparisons too much.

## Still skip locally for now

Compile-safe Late-QAT remains remote/CUDA-focused:

- `codex_notes/scratchpads/compile-safe-late-qat.md`
