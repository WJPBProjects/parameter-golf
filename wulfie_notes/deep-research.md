# OpenAI Parameter Golf: repo deep dive and experiment frontier map

OpenAI’s **Parameter Golf** is an open research challenge (hosted as a GitHub repo and mirrored by an OpenAI webpage) where the objective is to **train the best language model under extreme constraints**: the whole submission (training code + weights/serialization) must fit under a **16,000,000‑byte cap**, the training run must complete within **10 minutes on 8× H100 (SXM) GPUs**, and the score is **tokenizer-agnostic bits-per-byte (BPB)** on a fixed **FineWeb validation** split. citeturn37view0turn37view2

What makes this challenge unusually “researchy” is that the scoring is framed as a **compression objective** (BPB) rather than “token loss under a fixed tokenizer,” and the repo explicitly encourages pushing into unusual spaces like **test-time compute (including legal test-time training), aggressive parameter tying, depth reuse/recurrence, low-bit quantization/bitnets, novel tokenizers, long-context evaluation, and systems megakernels**. citeturn37view0turn28view4turn30view7

## Repo understanding

This section is written as a briefing for someone about to start hacking on the repo and/or creating a new `records/…` submission folder.

**Project layout and how “baseline vs SOTA” is intended to work.**  
The root scripts `train_gpt.py` (CUDA/PyTorch) and `train_gpt_mlx.py` (Apple Silicon/MLX) are explicitly meant as **starter baselines**, not the most competitive codepaths; competitive entries live in per-run folders under `records/`. citeturn37view0turn24view0turn26view0

**What a successful submission folder must contain.**  
The repo README defines the acceptance expectations for a run added under `records/…`: a **README.md** explaining the approach, a **submission.json** with metadata, at least one **training log**, and the exact **train script + dependencies** needed to reproduce from inside that folder (broken scripts aren’t accepted). citeturn37view0turn30view6turn38view0  
The `submission.json` convention in existing leaderboard folders is compact: fields like `name`, `val_bpb`, `bytes_total`, `blurb`, `author`, `github_id`, and `date` are typical. citeturn38view0turn38view1

**Dataset + tokenizer expectations (crucial for reproducibility).**  
The data tooling is built around a cached FineWeb export. The download helper `data/cached_challenge_fineweb.py` populates a canonical local layout with `data/datasets/...` and `data/tokenizers/...`, downloading (by default) the **full validation split** plus a prefix of training shards (default: **80 shards = ~8B retokenized training tokens** for the published export). citeturn37view0turn37view1  
Shards are `100,000,000` tokens each, and “train on first N shards” means training on a **prefix of a frozen shuffled export**, so the **data order stays aligned** within a tokenizer family—important for ablation comparability. citeturn37view1

**Baseline training script (`train_gpt.py`) is one-file, environment-variable driven.**  
The default baseline config (as of the current repo state) is called out directly: **9 transformer blocks, width 512, 8 attention heads with 4 KV heads (GQA), 2× MLP expansion, vocab size 1024, seq len 1024, tied embeddings**, trained with **524,288 tokens/step** and a **~10 minute wallclock cap** (nominally 20,000 iterations but wallclock-limited). citeturn24view0turn37view0  
Hyperparameters are almost entirely controlled via env vars (e.g., `TRAIN_BATCH_TOKENS`, `TRAIN_SEQ_LEN`, `NUM_LAYERS`, `MODEL_DIM`, `NUM_HEADS`, `NUM_KV_HEADS`, `MLP_MULT`, and optimizer LRs). citeturn24view0turn22view1

**Baseline architecture: a compact Transformer with U‑Net style skip reuse + per-channel learned scales.**  
Key architectural elements in the baseline CUDA model:

- **Encoder/decoder-style skip reuse (U‑Net-ish):** the model splits layers into an “encoder half” and a “decoder half”; the first half pushes intermediate activations onto a stack, and the second half **reuses them in reverse order**, with learned `skip_weights`. citeturn12view2turn14view0  
- **Tied embeddings (optional):** when `tie_embeddings=True`, logits are computed with `F.linear(x, tok_emb.weight)` (no separate head matrix), otherwise an untied `lm_head` is used. citeturn14view0turn24view0  
- **Grouped-query attention / KV head reduction:** attention is implemented with `num_heads` and `num_kv_heads` (must divide), and uses PyTorch SDPA with `enable_gqa` when KV heads differ from Q heads. citeturn13view6turn13view0  
- **ReLU² MLP:** baseline MLP does `relu(fc(x))` then squares before projecting back, a cheap nonlinearity used repeatedly in competitive records too. citeturn13view1  
- **Learned residual/attention/MLP scales + residual mixing:** each block has per-channel `attn_scale` and `mlp_scale`, and a learned 2-vector `resid_mix` that linearly mixes the current residual stream `x` with the original embedding stream `x0` per channel before attention + MLP. citeturn12view0turn13view2  
- **RoPE + q/k RMSNorm + learned q_gain:** attention uses rotary embeddings, RMS-norms `q` and `k` before RoPE, and applies a learned per-head `q_gain`. citeturn13view0turn13view6  
- **Logit softcap:** logits are “soft-capped” via `logit_softcap * tanh(logits_proj / logit_softcap)` to stabilize training at small scale. citeturn14view0turn24view0

A subtle but important implementation detail: linear weights are kept in **fp32 for optimizer/state quality**, but cast at matmul time (bf16 compute) via a custom `CastedLinear`. citeturn15view0turn24view0

**Muon optimizer vs Adam split (baseline CUDA).**  
The baseline uses a deliberate optimizer partitioning strategy:

- Token embeddings use **Adam** at `EMBED_LR` or `TIED_EMBED_LR` depending on tying. citeturn12view9turn24view0  
- Transformer “matrix parameters” (2D tensors in blocks, excluding control tensors) use **Muon**. Muon orthogonalizes 2D gradient updates with a Newton–Schulz iteration (`zeropower_via_newtonschulz5`) and applies momentum/Nesterov style buffering. citeturn24view0turn12view8  
- Vectors/scalars (and “control” tensors like scales) use Adam with `SCALAR_LR`. citeturn15view3turn24view0

This split is core to the repo’s philosophy: “matrices want Muon; small controls want stable fp32; embeddings want their own LR.” citeturn15view3turn24view0

**Tokenizer-agnostic BPB evaluation (how the repo actually computes it).**  
Rather than fixing a tokenizer, the baseline builds lookup tables for **byte cost per token** from a SentencePiece `.model` file, then computes BPB as:

- compute `val_loss` (cross-entropy, natural log),
- convert to `bits_per_token = val_loss / ln(2)`,
- compute `tokens_per_byte` using the LUT-estimated byte count of the tokenized validation stream,
- then `val_bpb = bits_per_token * tokens_per_byte`. citeturn24view0turn11view6

The LUT logic counts base UTF‑8 byte length for each token piece (special handling for SentencePiece’s leading `▁` convention) and adds an extra byte for inferred spaces depending on whether the previous token is a “boundary token.” citeturn24view0turn18view7  
The script explicitly warns that tokenizer edits will be scrutinized because mistakes could unfairly improve scores. citeturn24view0turn37view0

**Artifact accounting: post-training int8 + zlib (baseline), and “code bytes count.”**  
The baseline script measures submission size as **code bytes + compressed model bytes**, where the model is quantized post-training to an **int8 per-row/per-tensor** format, serialized, then **zlib-compressed** (level 9). It writes `final_model.int8.ptz`, reports sizes, then **decompresses and reloads** to verify the final BPB after the roundtrip. citeturn25view0turn37view0  
The repo FAQ makes the size accounting explicit: the cap is **decimal** 16,000,000 bytes (not 16 MiB), and evaluation forbids external downloads/network calls; the artifact must be self-contained. citeturn37view0

**MLX local path (`train_gpt_mlx.py`) vs CUDA main path.**  
The MLX script mirrors the baseline defaults but is designed for **local iteration on Apple Silicon**, adds memory controls (microbatch chunking and eager evaluation to cap unified-memory spikes), and still supports the same idea: serialize a raw artifact and an int8+zlib artifact, then validate by reload + eval. citeturn26view0turn27view0  
Unlike the CUDA script (which uses `torch.save`), MLX uses `pickle` to serialize the quantized object before zlib. citeturn27view0

**Where baseline is intentionally simple vs already optimized.**  
Baseline simplicity: no BigramHash features, no XSA, no custom int6/int5 packing, no zstd/lzma packing, no FlashAttention‑3 direct calls, no EMA/SWA, no test-time training. citeturn37view0turn24view0  
Baseline already-optimized choices: `torch.compile` for fullgraph compilation, bf16 compute with fp32 master weights, deterministic streaming loader (no dataloader workers), Muon for matrix params, and explicit warmup that primes compiled graphs then restores initial weights so “timed training” starts from the true initialization. citeturn15view3turn22view3turn20view6

## Constraint analysis

Think of Parameter Golf as a constrained optimization over **(architecture, training algorithm, tokenizer, compression format, eval protocol)** with multiple coupled budgets: artifact bytes, training wallclock, evaluation wallclock, and “spirit of the rules.”

**The 16MB artifact cap is a compression problem, not just a parameter count problem.**  
The repo defines the submission artifact as **(training code bytes) + (compressed model bytes)** under a hard cap of **16,000,000 total bytes**. citeturn37view0turn25view0  
This has two immediate implications:

1. **Code size is real but usually second-order**: many leaderboard entries report code sizes on the order of ~60–70KB, leaving ~15.93MB for weights. citeturn30view6turn31view6turn25view0  
2. **Compression ratio is a first-class metric**: if your quantization/packing improves “bits per stored parameter,” you can buy either more parameters (capacity) or more per-parameter fidelity (less quantization gap). This is exactly why mixed int5/int6, ternary/binary packing, zstd/lzma, and factored embeddings show up in records. citeturn10view4turn36view2turn34view8

A useful mental model is: you’re optimizing “BPB per artifact byte.” That pushes toward architectures whose learned weights are not only performant but also **compressible** (e.g., many repeated values, low entropy, structured patterns). Several records explicitly note artifact-size deltas as a reason to add depth or features. citeturn10view4turn31view6

**Tokenizer-agnostic BPB reshapes the incentives around vocabulary and embeddings.**  
The evaluation metric is intentionally not “loss under tokenizer X”; it measures BPB as average bits emitted per original byte of text under your tokenizer. citeturn24view0turn11view6turn37view0  
This favors strategies that **reduce tokens-per-byte** without increasing bits-per-token too much—i.e., better tokenization/compression of common substrings—while also dealing with the fact that embeddings can dominate parameter counts for small vocab vs large vocab in small models. The repo calls out embeddings as a major parameter sink and uses tokenizer-agnostic scoring to avoid locking in that tradeoff. citeturn11view4turn24view0  
It also creates a large “rules surface area”: tokenizer edits can be legitimate, but errors can unfairly improve scores, so such submissions are reviewed more carefully. citeturn24view0turn37view0

**The 10-minute training cap on 8×H100 implies “throughput beats elegance.”**  
Leaderboard runs often talk in terms of **ms/step** and “free steps” gained by kernel fusion or optimizer changes, because within a fixed 600s cap, improvements that reduce step time can translate directly into more optimization steps. citeturn28view0turn36view3  
For example, the current top leaderboard entry reports ~83.4ms/step for ~7,185 steps in 600s, and explicitly budgets hundreds of seconds for evaluation-time TTT on top of training. citeturn28view0turn28view5

This pushes you toward:
- **simple forward passes** (avoid adding per-token heavy compute unless it yields large BPB gain),
- **kernel-friendly ops** (fusion and FlashAttention variants show up repeatedly), citeturn29view5turn36view3  
- and training methods that converge quickly at small scale (Muon + careful schedules show up as part of the “meta stack”). citeturn24view0turn29view5

**Evaluation budget is also capped, and “test-time compute” is explicitly encouraged but tightly constrained.**  
The FAQ says evaluation must also fit under ~10 minutes on 8×H100 (in addition to the training cap), and is otherwise flexible (sequence length can differ from training). citeturn37view0  
Crucially, the repo explicitly forbids “cheating on test loss,” including training on validation tokens you haven’t already scored; it also clarifies a narrow legality condition for test-time training: you may only adapt on validation tokens **after** they’ve been evaluated (“graded”) in a score-first protocol. citeturn37view0turn28view4turn28view5

**What ideas look bad at first but can become good after systems work.**  
The repo encourages “signs-of-life first, then optimize systems later,” and maintains both a main 10‑minute leaderboard and an unlimited-compute / non-record track. citeturn37view0turn33view0  
The unlimited track examples (e.g., the 4-hour baseline; 2h+ binary bitnet) show how some methods need far more steps to shine than the 10-minute budget allows. citeturn33view0turn34view8

**What looks like a dead end under these rules (based on repo evidence).**  
Depth recurrence looks like the canonical “sounds perfect, fails in practice” idea at this scale. A long non-record report documents multi-day experiments and concludes looped/recurrent-depth transformers are not competitive within the 10-minute regime, with controlled comparisons showing a meaningful BPB gap favoring flat depth. citeturn35view1turn35view9  
This doesn’t prove recurrence is impossible—only that current known patterns (shared-block loops) have real “taxes” (step time overhead and compounded error) that dominate at 10 minutes. citeturn35view7turn35view8

## Existing strategy taxonomy

This taxonomy is grounded in what the repo’s **leaderboard** and **records folders** actually show has worked, plus what unusual entries teach about failure modes.

**The converging “meta stack” family (11L/512d, lots of small add-ons, int6+zstd).**  
Multiple leaderboard entries converge on a shared recipe: ~11 layers, 512d, GQA (8 heads / 4 KV), U‑Net skip reuse, 3× MLP, and a bundle of small parameter additions like SmearGate and BigramHash; then heavy compression via int6 + zstd, often with SWA/EMA and sometimes XSA or RoPE tweaks. citeturn29view5turn31view4turn30view3turn37view0  
Bottlenecks: quantization gap, training stability at longer seq length (2048 comes up often), and step time tradeoffs. citeturn30view6turn29view5  
Saturation: many of the “obvious” stabilizers (warmdown tuning, WD=0.04, EMA/SWA, partial RoPE) appear repeatedly, suggesting diminishing returns unless you change a major axis (activation, optimizer systems, or evaluation protocol). citeturn29view1turn30view1turn28view6

**Activation tweaks as surprisingly high leverage.**  
The top leaderboard run attributes ~‑0.003 BPB to a one-line activation change: replacing ReLU² with **LeakyReLU(0.5)²** in the MLP. citeturn28view2turn28view6turn38view0  
Why it helps (as argued in the record): preserves gradient flow through negative pre-activations while keeping the squared nonnegative output bias. citeturn28view2  
Bottleneck: might be architecture- and optimizer-dependent; could interact with quantization distribution. (This is an inference from how pervasive quantization is in winning stacks.) citeturn29view6turn34view7

**Attention modifications: XSA (Exclusive Self Attention) and efficient variants.**  
Several records show BPB wins from applying XSA to the deepest layers, designed to subtract the component of attention output aligned with a token’s own value vector. citeturn31view3turn32view6  
The “efficient partial XSA” entry emphasizes that naive XSA under GQA can waste memory via `repeat_interleave`, but a reshape/broadcast implementation avoids extra allocation and reduces overhead to ~2ms/step. citeturn32view2turn32view6  
Saturation: XSA appears in multiple top entries; further gains likely require either a new variant (different projection/subspace) or better integration with quantization/training. citeturn29view5turn28view7

**Positional encoding tweaks: partial RoPE and layerwise LN scaling.**  
A leaderboard record reports improvement from applying RoPE to only **16 of 64 head dims** plus scaling RMSNorm outputs by **1/√(layer_idx+1)**; both are “zero parameter” changes. citeturn30view1turn30view6  
A related note shows Late-QAT intended to activate during training did not due to `torch.compile` constant folding a class attribute, which is an important systems gotcha: if your improvement depends on runtime toggles, compilation may erase it. citeturn30view7turn15view3

**Optimizer and systems work: parameter banking + parallel Muon.**  
The top run includes “Parameter Banking + Parallel Muon”: replacing many individual linear weights with a small number of contiguous parameter banks and restructuring Muon’s orthogonalization/reduction to run batched and overlapping with comms. citeturn28view7turn38view0  
This is a clear example of “systems work buys steps”: small ms/step improvements can fund more training or more expensive evaluation protocols. citeturn28view7turn36view3

**Quantization/compression families: int6/int5 mixes, GPTQ-lite clipping, ternary/binary bitnets.**  
Compression is its own axis in the repo:

- Mixed int5/int6 lets a record “buy a 10th layer” by assigning cheaper int5 to MLP weights and int6 to attention weights, reporting artifact savings of ~1.86MB vs uniform int6. citeturn10view4  
- “GPTQ-lite” clip percentile search chooses among candidate clipping percentiles per row to minimize reconstruction MSE, reported as ~‑0.0006 BPB at zero training cost, plus EMA improvements and warmdown tuning. citeturn29view1turn29view3  
- Ternary and binary “bitnet” style submissions show much larger parameter counts under the same artifact limit by packing weights into trits/bits and using stronger (often FP8) handling for non-ternary parameters, plus heavier compression like LZMA; these are showcased both in 10‑minute (ternary) and unlimited compute (binary) tracks. citeturn36view2turn36view4turn34view8

Bottleneck: low-bit training/STE stability and convergence speed—binary in particular is reported to converge slower and to need many more steps to close gaps, which conflicts with the 10-minute constraint. citeturn34view7turn36view3

**Evaluation-time methods: sliding window eval, temperature scaling, and legal test-time training (TTT).**  
The repo leaderboard includes explicit “Sliding Window Eval” and “LoRA TTT” entries, underscoring that evaluation protocol choices matter and are “in bounds” so long as they follow the rules. citeturn37view0  
The top run adopts a legally constrained “score-first” test-time training protocol with 32K-token chunks and SGD adaptation only after each chunk is scored under `torch.inference_mode()`. citeturn28view4turn28view5turn37view0  
Underexplored edge: the rule boundary is strict; anything resembling training on unseen validation tokens is disallowed (and explicitly called out). citeturn37view0

**Underexplored spaces, explicitly called out by the repo.**  
The repo itself lists several “requests” that are not yet fully represented as strong leaderboard stacks: JEPA, text diffusion, H‑net tokenization, universal transformer, megakernels, state-space models, end-to-end TTT, and super long context. citeturn37view0

## Online PR scan update (March 27, 2026)

I did a quick direct scan of the live GitHub PRs after writing the original report, with an emphasis on:

- merged leaderboard-defining PRs like [#399](https://github.com/openai/parameter-golf/pull/399), [#417](https://github.com/openai/parameter-golf/pull/417), [#445](https://github.com/openai/parameter-golf/pull/445), and [#549](https://github.com/openai/parameter-golf/pull/549)
- strong open / non-record PRs like [#609](https://github.com/openai/parameter-golf/pull/609), [#756](https://github.com/openai/parameter-golf/pull/756), [#421](https://github.com/openai/parameter-golf/pull/421), [#418](https://github.com/openai/parameter-golf/pull/418), and [#461](https://github.com/openai/parameter-golf/pull/461)
- older PRs that matter for rules interpretation, especially [#390](https://github.com/openai/parameter-golf/pull/390)

The main update is simple: **the frontier has already moved beyond the merged README leaderboard**. The merged record in the repo README is still [#549](https://github.com/openai/parameter-golf/pull/549) at `1.1194`, but the strongest open/non-record PRs now point to a stronger frontier centered on **full GPTQ + XSA-all + aggressive artifact shaping**, not just more TTT.

### What still looks clearly real

**1. Throughput/system wins compose and keep compounding.**  
The strongest merged chain is still very instructive:

- [#399](https://github.com/openai/parameter-golf/pull/399) shows **Parameter Banking + Parallel Muon** as an architecture-agnostic throughput improvement (~3.4%) that later stacks inherit.
- [#549](https://github.com/openai/parameter-golf/pull/549) is explicitly built on the `#414 -> #399` stack and keeps the same overall structure while layering in LeakyReLU² and legal score-first TTT.
- [#609](https://github.com/openai/parameter-golf/pull/609) continues this pattern on an even stronger non-record stack, and explicitly notes that **FA3 vs slower attention backends is worth about ~0.004 BPB** because it buys back roughly ~1,000 training steps.

Takeaway: the repo is not in a regime where “ML trick” and “systems trick” are separable. If a systems change buys enough steps, it is effectively an ML improvement.

**2. LeakyReLU(0.5)^2 is no longer just a cute tweak; it looks robust.**  
The merged record [#549](https://github.com/openai/parameter-golf/pull/549) treats LeakyReLU(0.5)^2 as a meaningful, repeatable gain on top of an already strong stack, with the PR body describing it as about `-0.003 BPB` versus `relu^2`. This is not just a one-off baseline improvement anymore; it survives composition with stronger stacks.

**3. Legal score-first TTT is real, but stack-dependent.**  
The earlier frontier definitely benefited from legal score-first TTT:

- [#417](https://github.com/openai/parameter-golf/pull/417) reports a very large TTT improvement on its stack.
- [#461](https://github.com/openai/parameter-golf/pull/461) reports `1.14458` with a `-0.0165` legal TTT gain on a depth-recurrence non-record run.
- [#549](https://github.com/openai/parameter-golf/pull/549) reports about `-0.0025 BPB` from legal score-first TTT on the merged record stack.

So the original report was right to take TTT seriously. But the online PR scan also changes the conclusion on **how universal** that lever is, which matters for prioritization.

**4. Quantization/export sophistication is now a bigger frontier than generic architecture novelty.**  
The strongest open/non-record PRs are not winning because they discovered a brand-new backbone. They are winning by pushing:

- **full Hessian GPTQ**
- better calibration
- artifact-aware post-quant shaping
- XSA rolled out more aggressively
- tight systems engineering

The clearest example is [#609](https://github.com/openai/parameter-golf/pull/609), which reports:

- `1.1154` mean BPB
- `XSA on all 11 layers`
- `Selective ±1 magnitude pruning`
- `Full Hessian GPTQ int6 + lzma`
- `Parallel Muon`

This is materially better than the merged `1.1194` leaderboard record, even though it is still non-record/open.

### What the newer PRs say is working now

**XSA seems to want to go deeper than “last 4 layers.”**  
The most important single ablation from [#609](https://github.com/openai/parameter-golf/pull/609) is that applying **XSA on all 11 layers** gave about `-0.0016 BPB` relative to XSA-on-last-4, with zero new parameters. That is a stronger claim than the older report, which implicitly treated “XSA4” as the stable default.

**Selective post-GPTQ pruning looks better than blunt pruning.**  
[#609](https://github.com/openai/parameter-golf/pull/609) uses a very specific artifact-fitting trick: after GPTQ, sort quantized `±1` entries by reconstruction error proxy and zero the least harmful first. The negative-results table in the same PR says that naive “prune all ±1” style pruning is much too aggressive. This suggests a more general rule:

- **artifact shaping has to be distortion-aware**
- crude pruning is not enough
- fine-grained post-quant surgery may be a real frontier

**Self-generated GPTQ calibration is a big new idea.**  
The strongest genuinely new result from [#756](https://github.com/openai/parameter-golf/pull/756) is the calibration study:

- validation-data calibration: `1.11446`
- autoregressive self-generated calibration: `1.11477`
- random-token calibration: `1.11650`

That is a big deal for two reasons:

1. **self-generated calibration comes within `+0.00031 BPB` of validation-calibrated GPTQ**
2. even **random-token calibration already beats the merged README leaderboard**

If this result holds up, it means the export frontier may no longer require any fragile dependence on held-out natural-language calibration data. That should substantially raise the priority of “calibration source” experiments and lower the priority of more speculative eval-time adaptation work.

**Train-only replay looks like a legitimate small-but-real knob.**  
[#445](https://github.com/openai/parameter-golf/pull/445) is important because it gives a legal, modest improvement (`1.1236`) via **Late Training Replay** while explicitly avoiding validation-time TTT. This is a good example of a “cheap, clean, in-spirit” improvement that can compose with stronger stacks.

### What looks weaker, exhausted, or invalid

**1. Old-style eval-token TTT is explicitly invalid.**  
This is now much clearer online than in the original report. [#390](https://github.com/openai/parameter-golf/pull/390) was closed with an explicit note that adapting on validation tokens before scoring is invalid under issue `#402`. [#445](https://github.com/openai/parameter-golf/pull/445) was renamed specifically to clarify that its replay happens on training data only, and that it closed `#390` because `#390` used eval-token TTT.

That means older TTT ideas have to be mentally split into:

- **legal score-first TTT**: still valid
- **adapt-then-score eval TTT**: dead / invalid

**2. TTT is not a universally rising lever anymore.**  
This is the single biggest prioritization change. [#756](https://github.com/openai/parameter-golf/pull/756) says that on a `1.1142` stack, **25 legal TTT experiments failed across two stacks**, including:

- full-TTT: worse
- MLP-only TTT: neutral to worse
- smaller-unfrozen subsets: basically neutral

The PR’s interpretation is useful: once the stack already has **XSA-all** and a stronger quantization/export path, the earlier cross-document adaptation gains are mostly gone. In other words:

- TTT was very real on the mid-March frontier
- it may now be **partially exhausted** on the strongest current stacks

So generic “try more TTT variants” should be demoted from first-wave experiments.

**3. Several architecture ideas that sounded plausible appear negative on stronger stacks.**  
The negative-results table in [#609](https://github.com/openai/parameter-golf/pull/609) is especially valuable because it was run on a very strong stack. On that stack, these were negative or non-competitive:

- Value Residual Learning
- VRL sigmoid gates + TrigramHash
- Catalytic Residuals
- Backout connection
- Gated Attention + XSA-all
- Hadamard rotation + GPTQ
- TrigramHash
- BigramHash `4096` / `8192` under the same artifact budget
- stride `32` eval
- temperature scaling
- extended-context eval beyond the trained RoPE regime
- entropy coding beyond lzma

This is strong evidence that many “clever little add-ons” stop helping once the stack is already well-tuned for compression and throughput.

**4. Recurrence is still not back.**  
Even with a good legal TTT recipe, [#461](https://github.com/openai/parameter-golf/pull/461) lands at `1.14458` as a non-record unlimited-compute result. That is interesting and scientifically useful, but it does not overturn the original report’s conclusion that recurrence is still not where the frontier is for the main 10-minute track.

**5. DiffTransformer / NorMuon / trigram-heavy variants still look exploratory, not frontier.**  
[#418](https://github.com/openai/parameter-golf/pull/418) is valuable as an exploration, but `1.1715` post-quant BPB is nowhere near the live frontier. This weakens the case for spending first-wave effort on “architecturally novel but throughput-risky” attention alternatives unless they have a much clearer systems story.

**6. The mixed int5/int6 + memory tokens + backout + per-head temperature stack is interesting, but not yet competitive.**  
[#421](https://github.com/openai/parameter-golf/pull/421) is useful because it combines many plausible ideas, including a QAT fix, mixed int5/int6, large BigramHash, learnable memory tokens, backout connection, and per-head temperature. But the reported `1.1466` result and slower training setup suggest that this bundle is not yet on the shortest path to the frontier.

### Practical reprioritization after the PR scan

If I were revising the original report into a sharper experiment roadmap, I would change the priority ordering like this:

**Promote to top tier**

1. **Full GPTQ / calibration-source experiments**
2. **XSA-all and related “zero-parameter deeper mixing” ablations**
3. **Selective post-quant pruning / artifact-fitting heuristics**
4. **Throughput work that buys steps directly (Parallel Muon, FA3, layout changes)**
5. **Train-only replay / clean late-stage replay-style tricks**

**Keep as second tier**

1. compile-safe QAT
2. LeakyReLU² slope or activation-family sweeps
3. partial RoPE / LN-scale / zero-param geometry tweaks
4. embedding factorization + vocab ladder

**Demote**

1. generic TTT exploration as a first-wave priority
2. value-residual / gated-attention / backout / catalytic-residual style add-ons
3. trigramhash as an obvious next step
4. bigger BigramHash under the same artifact budget
5. temperature scaling / stride-32 obsession on already-strong stacks
6. recurrence as a leaderboard-oriented direction

**Keep mostly as non-record / science bets**

1. graph-inspired sparse token mixers
2. state-space hybrids
3. hierarchical pooling / graph coarsening
4. universal-transformer / recurrence ideas

## Massive idea bank

Below is a breadth-first bank of experiment ideas. Every item is written to be actionable in the context of this repo’s actual constraints and common patterns (U‑Net skips, GQA, relu² family, Muon+Adam splits, tokenization-BPB coupling, post-quant artifact accounting, and legal evaluation rules). citeturn24view0turn14view0turn25view0turn37view0

I’m intentionally mixing **low-risk ablations** with **weird moonshots** and calling out “likely traps.” When I mention a feature that exists in records but not baseline, I’m grounding it in records’ READMEs (because each record carries its own `train_gpt.py`). citeturn30view6turn31view6turn36view0

**A. Architecture ideas**

**Idea: “Factorized tied embedding everywhere”** (Complexity: medium; Signs-of-life: medium; Leaderboard: medium; Best as: medium engineering; Touches: record `train_gpt.py`, quantization code, tokenizer path).  
Core hypothesis: the most under-optimized part of BPB for larger vocabs is embedding/head cost; a **low-rank bottleneck embedding** (like the 8192×254 factorization used in the ternary record) can buy vocab-size improvements with less artifact cost. citeturn36view2turn24view0  
Why help: BPB directly rewards fewer tokens/byte; larger vocab can help if embeddings don’t dominate artifact. citeturn24view0turn37view0  
Why fail: low-rank bottlenecks can underfit rare token semantics; quantization artifacts may concentrate in projection matrices.  
First file: a records `train_gpt.py` that already supports bigger vocab (look at the 8192-BPE run patterns). citeturn36view4

**Idea: “Poly softcap in baseline stack”** (Complexity: medium; Signs: medium; Leaderboard: low–medium; Best as: quick ablation in a record fork; Touches: `GPT.forward` logits).  
Hypothesis: replacing tanh softcap with a polynomial softcap (as used in the binary/ternary bitnet runs) improves gradient behavior under aggressive quantization. citeturn14view0turn34view8turn36view2  
Why help: logits are a stability hotspot in small models; softcaps interact with low-bit noise.  
Why fail: may destabilize without Z-loss or careful tuning (ternary record mentions Z-loss). citeturn36view2

**Idea: “Per-block adaptive embedding injection schedule”** (Complexity: medium; Signs: medium; Leaderboard: low; Best as: exploratory).  
Hypothesis: the baseline’s `resid_mix` always mixes `x` and `x0`; add a schedule so deeper blocks get less direct `x0` injection once training stabilizes. citeturn12view0turn14view0  
Why help: could reduce “shortcut reliance” and improve context modeling (especially when XSA/partial RoPE remove some position cues). citeturn30view1turn31view3  
Why fail: may reduce stability, especially with Muon and low-bit export.

**Idea: “Token-conditional residual gates”** (Complexity: high; Signs: low–medium; Leaderboard: low; Best as: moonshot).  
Hypothesis: make `attn_scale`/`mlp_scale` functions of token features (tiny MLP on `x` producing per-channel gates). citeturn12view0turn13view2  
Why help: could allocate compute capacity to tokens that need it (compression view = pay bits where needed).  
Why fail: adds parameters and runtime; may hurt compressibility of weights and step time.

**Idea: “Virtual-token scratchpad blocks”** (Complexity: high; Signs: low; Leaderboard: low–medium; Best as: unlimited-compute precursor).  
Hypothesis: add a small fixed number of learned “memory” tokens appended to every sequence; attention mixes them; can help with long-range bias without increasing sequence length too much.  
Why help: similar to “global nodes” in sparse graph transformers; might help BPB if it improves global statistics modeling. citeturn40search3turn28view5  
Why fail: extra tokens raise compute quadratically in attention; strong step-time penalty.

**B. Recurrence / depth reuse / universal-transformer ideas**

**Idea: “Recurrence only at eval-time”** (Complexity: medium; Signs: medium; Leaderboard: low–medium; Best as: non-record / eval-only experiment).  
Hypothesis: depth recurrence failed in training-time budgets, but a small number of **extra refinement passes at eval** (no weight change) might improve likelihood a bit, trading eval time for BPB. Depth recurrence work in records suggests training-time recurrence is a bust in 10 minutes, but eval-time compute could be cheaper if implemented efficiently. citeturn35view1turn37view0  
Why help: evaluation budget allows more compute if <10 minutes. citeturn37view0  
Why fail: additional passes may not help next-token likelihood; could overrun eval budget.

**Idea: “Shallow recurrence with shared MLP only”** (Complexity: high; Signs: low; Leaderboard: low; Best as: scientifically interesting).  
Hypothesis: share only MLP weights across layers (not attention), reducing recurrence tax and keeping attention layerwise diversity; might avoid the failure mode reported for full shared-block loops. citeturn35view7  
Why help: MLP dominates parameters; sharing it buys bytes.  
Why fail: likely harms expressivity; quantization errors might compound.

**Idea: “Universal Transformer-style adaptive halting”** (Complexity: extreme; Signs: low; Leaderboard: probably trap).  
Hypothesis: adaptive computation time per token (halt earlier for easy tokens).  
Why it might help: ties to compression intuition.  
Why it likely fails here: huge code + compute complexity; hard to make kernel efficient; recurrence has negative evidence in repo already. citeturn35view1turn37view0

**C. Attention ideas**

**Idea: “XSA variants beyond ‘subtract self-value projection’”** (Complexity: medium; Signs: medium; Leaderboard: medium).  
Hypothesis: XSA works; try subtracting projection onto a **learned subspace** of v (e.g., top‑k dims via a tiny per-head linear) rather than full v direction. citeturn31view3turn32view6  
Why help: could remove only the harmful “self-bias” component while preserving useful self features.  
Why fail: adds parameters and may be fragile under int6 export.

**Idea: “Partial RoPE sweeps that are *not* 16/64”** (Complexity: low; Signs: high; Leaderboard: medium).  
Hypothesis: the 16/64 success suggests there’s a curve; test 8/64, 24/64, 32/64, and per-layer RoPE dims (less RoPE in deeper layers). citeturn30view1turn30view6  
Why help: might better balance positional bias vs invariance.  
Why fail: could hurt long-context generalization.

**Idea: “RoPE base as a learned scalar”** (Complexity: medium; Signs: low–medium; Leaderboard: low).  
Hypothesis: instead of a fixed `ROPE_BASE`, learn a global scalar or per-layer base multiplier (tiny parameter count) and quantize it as a control tensor. citeturn24view0turn25view0  
Why help: may tune position frequency spectrum to dataset.  
Why fail: could overfit; might break stability under compilation.

**Idea: “Head-wise q_gain regularization / initialization search”** (Complexity: low; Signs: high; Leaderboard: low–medium).  
Hypothesis: baseline has a per-head `q_gain` initialized to `QK_GAIN_INIT`. Sweep init and add a regularizer to keep q_gain near 1 to reduce quantization sensitivity. citeturn13view6turn24view0  
Why help: attention scale affects entropy and can explode logits.  
Why fail: gain may be critical for fast convergence (ternary run uses higher `QK_GAIN_INIT`). citeturn36view6

**Idea: “Expander sparse attention pattern over sequence positions”** (Complexity: high; Signs: low–medium; Leaderboard: medium if fast).  
Hypothesis: borrow expander-graph sparse attention ideas from graph transformers and apply them to token positions: each token attends to local window + a few expander edges + optional global token. citeturn40search3turn40search11  
Why help: could raise effective context at near-linear cost, allowing longer seq_len without quadratic blowup.  
Why fail: implementing fast sparse attention in PyTorch may be too slow; might need custom kernels (engineering-heavy).

**D. MLP / gating / activation ideas**

**Idea: “LeakyReLU² slope sweep + per-layer slope”** (Complexity: low; Signs: high; Leaderboard: high).  
Hypothesis: slope=0.5 worked; test slopes (0.1, 0.2, 0.3, 0.7) and optionally make slope per-layer (stored as fp32 control tensor). citeturn28view2turn25view0  
Why help: can fine-tune gradient flow vs sparsity.  
Why fail: per-layer slopes add parameters and may not compress well.

**Idea: “SwiGLU / gated MLP as a capacity-per-byte win”** (Complexity: medium; Signs: medium; Leaderboard: medium).  
Hypothesis: a non-record run explored SwiGLU and saw improvements even on weaker hardware; gated MLPs might improve expressivity at similar parameter counts. citeturn34view0  
Why help: often improves LM quality at fixed width.  
Why fail: may be slower; may quantize worse than relu².

**Idea: “Activation-aware quantization shaping”** (Complexity: medium; Signs: medium; Leaderboard: medium).  
Hypothesis: choose activation (relu² vs leakyrelu² vs gated) that yields weight distributions more compressible under int6/zstd or bitpacking. Evidence: records explicitly discuss quantization gap management. citeturn29view3turn35view5  
Why fail: distribution shaping is subtle; can be swamped by other factors.

**Idea: “Per-channel MLP_scale initialization for depth”** (Complexity: low; Signs: medium; Leaderboard: low).  
Hypothesis: initialize `mlp_scale` smaller in deeper layers to reduce early instability, similar in spirit to LN scale 1/√(layer) that helped. citeturn13view2turn30view1  
Why help: stability under rapid training matters.  
Why fail: might slow learning too much within 600s.

**E. Embedding / output layer ideas**

**Idea: “BigramHash generalization: trigram / rolling hash / multibucket”** (Complexity: medium; Signs: medium; Leaderboard: medium).  
Hypothesis: BigramHash embeddings appear as a recurrent winning feature. Try multiple hash tables (e.g., 2–3 independent hashes) or include trigram hashes for richer short-range modeling at small param cost. citeturn31view4turn28view7turn10view4  
Why help: BPB rewards capturing local compressible patterns (common word/space bigrams).  
Why fail: diminishing returns; may add compute.

**Idea: “Embedding quantization asymmetry”** (Complexity: medium; Signs: medium; Leaderboard: medium).  
Hypothesis: many stacks use int8 embeddings and int6 elsewhere; explore per-row int6 embeddings for mid-frequency rows while keeping top‑k rows fp16/fp32 (control via keep-float patterns). citeturn29view6turn25view0  
Why help: embeddings are large; optimizing their bitwidth is huge for artifact.  
Why fail: embedding quantization errors can be catastrophic, especially for BPB.

**Idea: “Boundary-token engineering”** (Complexity: high and rule-sensitive; Signs: low; Leaderboard: probably trap).  
Hypothesis: because BPB uses a specific byte-counting heuristic for SentencePiece, you could try designing tokenization that legitimately reduces byte count under that heuristic.  
Why it’s risky: tokenizer edits are scrutinized; errors can unfairly improve scores; and anything that smells like metric gaming is likely disqualified. citeturn24view0turn37view0  
I would only pursue this if it clearly improves *true* compression and can be audited.

**F. Optimizer / schedule ideas**

**Idea: “Warmdown bug audit + standardization”** (Complexity: low; Signs: high; Leaderboard: medium).  
Hypothesis: a non-record run found a “warmdown fix” significant enough to log as hardware-agnostic. Audit warmdown logic across record scripts, and make sure the chosen schedule matches intended semantics under wallclock-based stopping. citeturn34view0turn22view2  
Why help: schedules matter more when you only get ~7k steps. citeturn28view0turn30view6  
Why fail: current top stacks likely already tuned warmdown heavily.

**Idea: “Muon backend steps sweep conditional on quantization regime”** (Complexity: low; Signs: medium; Leaderboard: low–medium).  
Hypothesis: Muon’s Newton–Schulz steps (`MUON_BACKEND_STEPS`) trade compute for update quality; ternary runs explicitly change this (3 steps) for STE attenuation reasons. citeturn36view3turn24view0  
Why help: might be under-tuned for int6 vs int5 vs bitnets.  
Why fail: step-time cost can erase gains.

**Idea: “Per-parameter-group WD decoupling for shared vs unshared weights”** (Complexity: medium; Signs: medium; Leaderboard: low).  
Hypothesis: recurrence report suggests WD effects can compound on shared weights; even without recurrence, some parameters (e.g., embeddings) may want different WD from matrices. citeturn35view7turn12view8  
Why help: reduce over-regularization in the highest-leverage tensors.  
Why fail: adds tuning surface area; risk of overfitting.

**G. Quantization / compression ideas**

**Idea: “Generalize GPTQ-lite: percentile grid + per-module budgets”** (Complexity: medium; Signs: high; Leaderboard: high).  
Hypothesis: GPTQ-lite already yields measurable BPB gains by searching clip percentiles per row. Extend it with module-level budgets: more candidates for attention projections, fewer for MLP, or even search “clip percentile × bitwidth” per tensor block. citeturn29view1turn29view3  
Why help: quantization is a dominant bottle-neck in all strong stacks. citeturn30view6turn31view6  
Why fail: complexity; risk of evaluation-time blowup.

**Idea: “Mixed precision beyond int5/int6: int4 for select layers”** (Complexity: high; Signs: low–medium; Leaderboard: medium).  
Hypothesis: int5 MLP freed enough bytes for an extra layer; perhaps some deeper MLP blocks can be int4 while keeping attention int6. citeturn10view4  
Why help: more layers/width per artifact.  
Why fail: int4 quantization error likely too large unless paired with QAT or stronger clipping/search.

**Idea: “Bitpacking for int6/int5 (not just binary/ternary)”** (Complexity: high; Signs: medium; Leaderboard: medium).  
Hypothesis: binary/ternary entries show bitpacking + LZMA can be huge; similar packing for int5/int6 might beat zstd in some regimes if implemented carefully. citeturn34view8turn10view4  
Why help: better compression yields more capacity.  
Why fail: engineering complexity; may not outperform zstd on noisy int6 arrays.

**Idea: “FP8 for ‘non-compressible’ leftovers”** (Complexity: high; Signs: medium; Leaderboard: low–medium).  
Hypothesis: ternary/binary stacks use FP8 QAT for non-binary parameters to halve size with low RT penalty. Even in int6 stacks, FP8 for certain tensors (e.g., embeddings or control maps) might reduce bytes without severe BPB loss. citeturn36view4turn34view8  
Why fail: fp8 tooling complexity; might not compress well with zstd.

**Idea: “Quantization-gap-first training objective”** (Complexity: high; Signs: medium; Leaderboard: medium).  
Hypothesis: explicitly regularize weights to be robust to the exact export quantizer (e.g., add noise matching step size), as recurrence report shows “noisy QAT” can collapse quantization gaps when calibrated correctly. citeturn35view5turn30view7  
Why fail: needs careful avoidance of compile dead-code elimination; must be integrated in traced graph. citeturn30view7

**H. Tokenization ideas**

**Idea: “Vocabulary size ladder: 1024 → 2048 → 4096 → 8192 with embedding factoring”** (Complexity: high; Signs: medium; Leaderboard: medium).  
Hypothesis: the ternary/binary stacks show 8192 BPE is viable under 16MB with factored embeddings. Try bringing 2048/4096/8192 vocab into the meta stack, but pay for embeddings via factorization. citeturn36view2turn34view8turn24view0  
Why help: lower tokens/byte can directly reduce BPB if bits/token doesn’t rise too much. citeturn24view0turn37view0  
Why fail: bigger vocab may slow convergence in 10 minutes; might worsen bits/token more than it improves tokens/byte.

**Idea: “Tokenizer retraining against the published docs cache”** (Complexity: medium; Signs: medium; Leaderboard: low–medium).  
Hypothesis: because the repo provides a reproducible docs cache workflow (with doc SHA), you can try tokenizer variants while keeping data selection aligned, reducing ambiguity. citeturn37view1  
Why fail: heavy scrutiny; you must demonstrate BPB correctness. citeturn37view0turn24view0

**I. Evaluation-time and test-time compute ideas**

**Idea: “Legal score-first TTT variants: freeze subsets, fewer epochs, LoRA-only”** (Complexity: medium; Signs: high; Leaderboard: high).  
Hypothesis: the top run gets ~‑0.0025 BPB from legal score-first TTT with full-block SGD. Try variants: freeze early layers, adapt only scale/control tensors, or LoRA adapters, to reduce eval cost and reduce catastrophic drift. citeturn28view4turn28view6turn37view0  
Why help: TTT is one of the few levers that can improve BPB without increasing artifact bytes (if code stays small) by spending evaluation compute instead. citeturn37view0turn28view5  
Why fail: rule-sensitive; must maintain strict “score-first; train-after-scoring” discipline. citeturn28view5turn37view0

**Idea: “Per-chunk temperature calibration”** (Complexity: low; Signs: medium; Leaderboard: low–medium).  
Hypothesis: a binary non-record run reports an “optimal_T” temperature scaling; perhaps a lightweight global calibration on already-scored chunks improves bits/token. citeturn34view5turn35view9  
Why fail: might be minimal; can overfit per-chunk.

**Idea: “Stride sweep for sliding-window eval”** (Complexity: low; Signs: high; Leaderboard: medium).  
Hypothesis: multiple runs report stride differences (64 vs 16) and large BPB effects. This is an easy lever within evaluation budget. citeturn36view4turn34view5turn37view0  
Why fail: too-small stride may exceed evaluation wallclock cap. citeturn37view0turn28view5

**J. Data-order / curriculum / sequence-packing ideas**

**Idea: “Seq length curriculum (1024→2048) with NTK-aware RoPE or partial RoPE”** (Complexity: medium; Signs: medium; Leaderboard: medium).  
Hypothesis: many strong stacks train/eval at 2048 with NTK-aware RoPE; try ramping seq_len over training to keep early steps fast and later steps long-context. citeturn29view5turn30view3turn22view2  
Why fail: many implementations exist; gains may be marginal.

**Idea: “Batch tokens schedule (smaller early, larger late)”** (Complexity: medium; Signs: low–medium; Leaderboard: low).  
Hypothesis: ternary run notes 524k batch tokens as optimal; for bf16/int6 stacks, perhaps smaller batch early increases update count, larger batch late stabilizes for quantization robustness. citeturn36view3turn24view0  
Why fail: schedule complexity; may reduce throughput.

**K. Code-size / artifact-structure ideas**

**Idea: “Strictly separate ‘training script’ from ‘export script’ inside one file via minimal DSL”** (Complexity: medium; Signs: medium; Leaderboard: low).  
Hypothesis: code bytes are counted; keeping code small matters when you start adding complex packing (bitpacking, LZMA tables, etc.). Baseline counts `len(code.encode("utf-8"))` directly. citeturn25view0turn37view0  
Why fail: Python code golf can hurt readability and reproducibility.

**Idea: “Compression-aware parameter naming to exploit keep-float patterns”** (Complexity: low; Signs: low; Leaderboard: low).  
Hypothesis: baseline has name-pattern-based “keep float fp32” logic for control tensors. If you add new control tensors, make sure naming fits patterns so they stay fp32. citeturn25view0turn15view2  
Why fail: small effect; mostly housekeeping.

**L. Weird ideas still plausibly in spirit**

**Idea: “State-space model hybrid block: Mamba-style mixer inside 11L stack”** (Complexity: extreme; Signs: low; Leaderboard: medium if it fits).  
Hypothesis: replace attention in some layers with a selective SSM mixer (Mamba) to get long-context mixing at linear cost. citeturn39search1turn37view0  
Why help: could enable longer effective contexts or cheaper eval-time passes.  
Why fail: major engineering; unclear how to quantize/compress SSM parameters under int6/zstd; might be too slow in PyTorch without custom kernels.

**Idea: “Graph-style token mixing: fixed sparse adjacency over positions + message passing”** (Complexity: high; Signs: low–medium; Leaderboard: medium).  
Hypothesis: treat tokens as nodes in a fixed sparse graph (local + expander + global) and run message passing layers instead of attention; could approximate global mixing cheaply. citeturn40search3turn40search1  
Why fail: implementing fast message passing at sequence lengths (1024–4096) might still be slower than FlashAttention.

**Idea: “Test-time learning via perplexity minimization on already-scored tokens”** (Complexity: high; Signs: medium; Leaderboard: medium).  
Hypothesis: adapt the TTT loss to be an unsupervised objective like input perplexity minimization, but restricted to already-scored chunks to stay legal. citeturn39search7turn37view0turn28view5  
Why fail: could cause drift; might violate “spirit” if adaptation becomes too aggressive, even if rule-compliant.

*(I’m stopping the idea list here to keep the report finite; in a real internal planning doc I’d continue to ~80–120 ideas. The highest-yield next expansions would be: more quantizer families (Hessian-aware, groupwise), more tokenization variants, and more “microkernel/systems” ideas suggested by the repo itself.)* citeturn37view0turn29view1turn28view7

## Graph neural network and graph-architecture section

This section focuses on whether **graph-inspired architectures** can be useful *in spirit and in practice* for Parameter Golf.

**Why graph ideas are not obviously silly here.**  
A token sequence is already a graph: nodes are token positions; edges can be local (adjacent tokens), long-range (attention), or structured (expander / dilated / learned rewiring). Graph neural networks (GNNs) are fundamentally **message-passing systems** over graphs, and attention itself can be viewed as a learned message-passing operator. Classic formulations like MPNNs formalize this as learned message functions + aggregation. citeturn40search1turn39search2  
Graph Transformers (e.g., Graphormer, Graph Transformer generalizations) emphasize the importance of encoding structure and using global attention carefully; sparse graph transformers like Exphormer explicitly use **virtual global nodes and expander graphs** to get scalable long-range mixing. citeturn40search0turn40search2turn40search3

**Legality / spirit check.**  
All graph-inspired ideas below are “in spirit” if they:
- are self-contained (no network calls at eval), citeturn37view0  
- respect training vs validation separation (no training on unseen validation tokens), citeturn37view0turn28view5  
- stay under artifact bytes, and fit train+eval wallclock budgets. citeturn37view0turn25view0

### Graph-inspired directions and how they map onto this repo’s constraints

**Token-to-token message passing instead of full attention (fixed sparse graphs).**  
Core idea: replace quadratic attention with message passing on a sparse graph (e.g., local window + a few long edges). This resembles graph transformer sparsification strategies (expander + virtual global nodes). citeturn40search3turn40search11  
- Likely legality: yes (it’s just a different architecture).  
- Wallclock risk: medium–high; naive sparse ops in PyTorch can be slower than FlashAttention even if asymptotically cheaper.  
- Artifact risk: low (graph connectivity can be implicit, parameter-free).  
- Incremental implementation: plausible by swapping `scaled_dot_product_attention` for a custom sparse mix in a record `train_gpt.py`, but it’s engineering-heavy. citeturn13view0turn37view0  
- Best use: **non-record exploratory** first to validate BPB per step; only later try to optimize kernels for leaderboard.

**Sparse dynamic graphs over the sequence (content-dependent edges).**  
Core idea: compute edges based on token similarity or hashing (like BigramHash but extended), then do message passing along selected neighbor edges. This is akin to attention but with hard sparsity.  
- Likely legality: yes.  
- Wallclock risk: high: edge selection itself can dominate runtime.  
- Artifact risk: low if edge selection is computed on the fly.  
- Incremental path: start with a deterministic, hash-based neighbor set (cheap) rather than learned kNN.

**Learnable graph rewiring with local neighborhoods (graphormer-style structural bias).**  
Graphormer argues that encoding structural information is essential for graph Transformers to work well. citeturn40search0  
For sequences, “structure” is trivial (positions), but you can add structural biases like “same wordpiece class,” punctuation edges, or whitespace edges derived from tokenizer metadata, which the repo already touches via its byte LUT logic and boundary tokens. citeturn24view0turn18view7  
- Likely legality: yes.  
- Wallclock risk: low if biases are simple.  
- Artifact risk: medium if you add large bias tables.

**Latent memory nodes / virtual nodes.**  
Exphormer uses virtual global nodes + expander edges to improve scalability in graph transformers. citeturn40search3turn40search11  
For Parameter Golf, virtual nodes could act as a small “statistical summary” buffer.  
- Wallclock risk: medium (extra tokens increase attention cost).  
- Artifact risk: low.  
- Most promising role: **eval-time compute**, where a few extra refinement steps might be allowed if within eval budget. citeturn37view0

**Graph pooling / coarsening and unpooling (hierarchical token graphs).**  
Idea: compress the sequence into a shorter latent graph (pooling), run global mixing cheaply, then unpool back. This is “pay compute to build a multiscale representation.”  
- Likely legality: yes.  
- Wallclock risk: extreme; more ops and memory traffic, likely too slow in 10 minutes unless heavily fused.  
- Artifact risk: medium (pool/unpool parameters).  
- Recommendation: **probably a trap** for the main leaderboard, but could be a valuable non-record research contribution.

**Spectral / Laplacian parameterizations that compress well.**  
Graph Laplacians and expander graphs come with strong spectral properties; Exphormer motivates expander sparsity partly via theory. citeturn40search3turn40search7  
For sequences, you could parameterize mixing matrices via a small set of spectral coefficients (e.g., fixed FFT/DCT-like bases) and learn only diagonal scales.  
- Likely legality: yes.  
- Artifact risk: low (few learned coefficients).  
- Wallclock risk: medium depending on implementation.  
- Promising as: “unlimited-compute precursor” to validate whether spectral mixing can compete with attention BPB.

### Comparison against other contenders under the rules

Against **standard attention**: graph methods can win on *asymptotic* compute, but Attention is heavily optimized via FlashAttention and SDPA; sparse graph ops often lose in practice unless you have custom kernels. citeturn13view0turn29view5  
Against **recurrent depth reuse**: recurrence has negative evidence in the repo within the 10‑minute constraint. Graph sparsity could be a better route to “more effective context” without the recurrence step-time tax, but only if implemented efficiently. citeturn35view1turn35view8turn40search3  
Against **state-space models**: Mamba-like selective SSMs are designed for linear-time long-sequence modeling and have strong long-context claims, but implementing them in this repo with compatible quantization and GPU efficiency is a major undertaking. citeturn39search1turn39search13  
Against **MLP mixers / token mixers**: graph message passing can be seen as a structured token mixer. The upside is you may get some of attention’s long-range benefits with fewer parameters, but again the systems cost is the main risk.

## Reading list

This reading list prioritizes things that connect directly to Parameter Golf’s constraints: **tokenizer-agnostic BPB**, **small artifacts**, **low-bit quantization**, **fast training**, and **evaluation-time adaptation**.

**Dataset and metric grounding**
- **FineWeb dataset documentation + paper (“Decanting the Web…”)**: understand how FineWeb was built and what its filtering/dedup pipeline implies for modeling and tokenization choices. citeturn39search0turn39search12turn39search4  
- **FineWeb dataset card(s)**: useful for practical details and variants (FineWeb, FineWeb‑Edu). citeturn39search4turn39search24  
- **Repo’s BPB computation code**: not a paper, but you should treat it as canonical—especially if you plan tokenizer changes. citeturn24view0turn37view0  

**State-space and long-context alternatives**
- **Mamba (Selective State Spaces)**: a leading non-attention sequence backbone; relevant if you explore state-space mixers or hybrid blocks in Parameter Golf. citeturn39search1turn39search5turn37view0  
- **Survey on Structured State Space Models (S4→Mamba→successors)**: helpful map of the design space and implementation issues; good for generating ablations that might fit in 10 minutes. citeturn39search13turn39search9  

**Test-time training / test-time learning**
- **Test-Time Learning for Large Language Models (TTL/TLM)**: directly relevant to “legal test-time training” because it frames adaptation objectives and stability issues for LLMs under distribution shift. citeturn39search7turn39search15  
- **TTT for few-shot reasoning**: relevant for thinking about low-step, high-leverage adaptation, even if the exact method must be adapted to the “already-scored tokens only” legality constraint. citeturn39search19  
- **Repo’s legality framing for TTT**: again not a paper, but defining for what is allowed. citeturn37view0turn28view5  

**Graph methods for sequence mixing inspiration**
- **Graph Attention Networks (GAT)**: core attention-based message passing; useful reference point for token-graph mixing variants. citeturn39search2turn39search14  
- **Message Passing Neural Networks (MPNNs)**: unified view of message passing; helpful for designing “attention-lite” token mixers. citeturn40search1turn40search5  
- **Graphormer**: shows how to make Transformers work well on graphs with structural encodings—useful analogies for adding structure to token mixing. citeturn40search0turn40search12  
- **Graph Transformer generalization (Dwivedi & Bresson)**: another strong baseline framework for graph-transformer design patterns. citeturn40search2turn40search6  
- **Exphormer (sparse graph transformers with expander graphs + virtual nodes)**: particularly relevant because “expander-like sparse connectivity” is one of the most plausible graph-inspired routes to long-range mixing at low cost. citeturn40search3turn40search7turn40search11  

**Repo-embedded reading (high signal for Parameter Golf specifically)**
- **Depth recurrence post-mortem in `records/track_non_record_16mb`**: valuable because it’s a controlled negative result and includes concrete guidance about why recurrence is a trap at 10 minutes. citeturn35view1turn35view9  
- **Top leaderboard run READMEs**: treat them as “applied research notes” on what actually works in this codebase (e.g., LeakyReLU², GPTQ-lite, XSA, partial RoPE, parameter banking, legal TTT). citeturn28view6turn29view1turn31view3turn30view1turn28view7  

## Prioritized action plan

This is an opinionated roadmap designed for a small team moving fast. I’m optimizing for “expected BPB gain per engineering hour,” *and* for generating valuable non-record research artifacts when something is risky.

### Update after the online PR scan

The original action plan was slightly too optimistic about generic TTT and slightly too conservative about quantization/export work. After looking at the newer PRs, the revised frontier looks like this:

- first-wave work should concentrate on **full GPTQ, calibration source, XSA-all, selective pruning, and systems throughput**
- **legal score-first TTT is real but no longer obviously the best next lever** on the strongest stacks
- the strongest “cheap asymmetric” idea may now be **self-generated or random-token GPTQ calibration**, because [#756](https://github.com/openai/parameter-golf/pull/756) suggests it gets extremely close to validation-calibrated GPTQ without external-data fragility
- architecture-side “small clever additions” like gated attention, backout, value residuals, trigramhash, and temperature scaling should be treated as **mostly deprioritized on top-tier stacks** unless a new stack makes them natural again

### Top experiments to try first

**Self-generated GPTQ calibration on a strong stack**  
Hypothesis: the next real frontier is not “new model math,” it is better **artifact construction**. [#756](https://github.com/openai/parameter-golf/pull/756) suggests autoregressive self-generated calibration gets within `+0.00031 BPB` of val-calibrated GPTQ, and even random-token calibration is surprisingly strong.  
Minimal implementation: take a strong GPTQ-capable stack, calibrate once with held-out val-style data, once with self-generated samples, once with random tokens, and compare post-quant roundtrip BPB and runtime.  
Success signal: self-generated calibration reproduces the tiny gap reported in `#756`, and stays stable across seeds/stacks.  
Failure signal: it only works on one stack or adds too much wallclock.  
Next if promising: combine with selective pruning and module-aware clipping.

**XSA-all on top of the strongest currently reproducible stack**  
Hypothesis: [#609](https://github.com/openai/parameter-golf/pull/609) is probably the most important online update to the original report; `XSA-all` looks better than “XSA on the last 4 layers” on a modern strong stack.  
Minimal implementation: promote XSA from “deepest layers only” to all layers, hold everything else fixed, and rerun 2-3 seeds.  
Success signal: a consistent `~0.001+` BPB gain with no artifact penalty.  
Failure signal: it only helps on one seed or hurts step time enough to erase the win.  
Next if promising: test whether XSA-all changes the usefulness of TTT, replay, or calibration.

**Selective post-GPTQ pruning instead of blunt pruning**  
Hypothesis: [#609](https://github.com/openai/parameter-golf/pull/609) suggests artifact-fitting by selectively zeroing the least damaging `±1` weights is materially better than naive magnitude pruning.  
Minimal implementation: add a post-quant pass that ranks candidate removals by reconstruction proxy and trims only until the artifact target is met.  
Success signal: better post-quant BPB at the same artifact budget than simple pruning.  
Failure signal: either negligible gains or export/runtime complexity dominates.  
Next if promising: extend the criterion from `±1` entries to other near-zero quantized states.

**LeakyReLU² slope sweep on the current best stack**  
Hypothesis: the activation tweak is both cheap and high-leverage; slope may not be optimized. citeturn28view2turn38view0  
Minimal implementation: change the MLP activation line (as in the top record) and rerun seeds at slopes {0.2, 0.3, 0.5, 0.7}. citeturn28view2  
Success signal: consistent ≥0.0005–0.001 BPB improvement across 3 seeds post-quant + post-TTT (if used). citeturn28view0turn30view6  
Failure signal: improvement only in pre-quant or only in one seed.  
Next if promising: add per-layer slope (stored as a control tensor so it stays fp32). citeturn25view0turn15view2  

**Refactor Late-QAT so it cannot be compile-eliminated**  
Hypothesis: QAT-style improvements have upside, but `torch.compile` can dead-code-eliminate toggles if they’re class attributes. citeturn30view7turn15view3  
Minimal implementation: make the QAT “enabled” flag a tensor or module buffer checked in the forward graph, not a Python-level constant.  
Success: quantization gap shrinks (roundtrip BPB closer to pre-quant) without hurting step time too much. citeturn30view6turn29view1  
Failure: no change, or step time rises enough to lose more BPB from fewer steps.  
Next: combine with GPTQ-lite clipping to reduce gap further. citeturn29view3

**GPTQ-lite expanded search (module-aware)**  
Hypothesis: “clip percentile search” is already proven; optimizing it per module family could deliver more without training cost. citeturn29view3turn29view1  
Minimal implementation: increase candidate percentiles for attention projections only, keep MLP candidates small to control runtime.  
Success: post-quant BPB improves by ≥0.0005 with negligible eval overhead.  
Failure: eval-time overhead breaks the 10-minute eval budget. citeturn37view0turn28view5  
Next: move from percentile grid to a tiny per-row “fit best clip” heuristic.

**TTT ablations under the legal score-first protocol**  
Hypothesis: TTT is now a **conditional** lever, not an automatic one. It clearly worked for [#549](https://github.com/openai/parameter-golf/pull/549), but [#756](https://github.com/openai/parameter-golf/pull/756) says 25 legal TTT experiments failed on a stronger `1.1142` stack. That makes this a second-wave ablation, not a first-wave default.  
Minimal implementation: keep scoring identical; during TRAIN, restrict grads to (a) last N layers, (b) only scale/control tensors, (c) LoRA-like low-rank adapters.  
Success: same or better BPB gain at less eval time on the current stack.  
Failure: neutral or worse results, which would confirm the “TTT is exhausted on strong stacks” interpretation.  
Next: only continue TTT work if it clearly composes with XSA-all / stronger calibration; otherwise stop early.

**Partial RoPE × LN-scale grid search**  
Hypothesis: both were zero-param wins; the best combination may not be 16/64 with 1/√(layer+1). citeturn30view1turn30view6  
Minimal: sweep RoPE dims {8, 16, 24, 32} and LN scaling schedules {none, 1/√(l+1), 1/(l+1)}.  
Success: consistent improvement across seeds.  
Failure: unstable training or worse long-context eval.

### Medium-term bets

**Expander-style sparse token mixing prototype**  
Why: highest-upside “new architecture” path that plausibly offers long-range mixing cheaper than attention at larger seq_len. citeturn40search3turn37view0  
Plan: non-record first (prove BPB vs steps), then optimize kernels.

**State-space hybrid layer (Mamba-like) in 1–2 layers only**  
Why: reduces risk vs full replacement; tests whether SSM mixing helps BPB quickly. citeturn39search1turn39search13  
Plan: unlimited compute precursor; only later attempt to make it 10-minute competitive.

**Embedding factorization + vocab ladder**  
Why: BPB is sensitive to tokenization; larger vocab is tempting but expensive unless embeddings are handled. citeturn36view2turn24view0  

### Wild moonshots

**Binary/ternary training that converges within 10 minutes**  
The repo already demonstrates strong binary/ternary outcomes with more compute or different step budgets; the moonshot is getting that to converge fast enough for the main track. citeturn34view7turn36view3  

**Graph pooling / hierarchical token graphs**  
Scientifically interesting, likely too slow, but could produce novel insights.

**End-to-end test-time learning for LLMs under legality constraints**  
Ground it in TTL/TLM-style objectives but constrained to already-scored tokens. citeturn39search7turn28view5  

### Best candidates for valuable non-record submissions even if not SOTA

- A careful expander-sparse token mixer baseline (even if slow). citeturn40search3turn37view0  
- A Mamba-hybrid block prototype with quantization notes. citeturn39search1turn39search13  
- A tokenizer + embedding factorization study with BPB correctness proof steps. citeturn37view0turn37view1  
- A “compile gotchas” writeup: how to avoid constant-fold elimination (already hinted by the Late-QAT postmortem). citeturn30view7turn15view3  
- A systematic eval-time compute sweep (stride, temperature scaling, chunk sizes) that stays within the explicit eval budget. citeturn37view0turn34view5turn36view4  

### Cheap experiments with unusually asymmetric upside

- LeakyReLU² slope sweep (tiny code change; already proven directionally). citeturn28view2  
- Partial RoPE dim sweep (zero new params; already proven at one point). citeturn30view1  
- GPTQ-lite candidate expansion (post-training only). citeturn29view3  
- Eval stride grid + time budget logging (simple, but can move score materially). citeturn36view4turn37view0  
- Fix Late-QAT compile elimination (could unlock an entire family of QAT ideas that are currently “silently off”). citeturn30view7
