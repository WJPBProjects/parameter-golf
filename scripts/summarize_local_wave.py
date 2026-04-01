#!/usr/bin/env python3

from __future__ import annotations

import re
import sys
from pathlib import Path


START_RE = re.compile(r"^START \[(?P<label>[^\]]+)\] profile=(?P<profile>\S+) dir=(?P<dir>.+)$")
END_RE = re.compile(r"^END \[(?P<label>[^\]]+)\] status=(?P<status>\d+)$")
POST_QUANT_RE = re.compile(
    r"final_int8_zlib_roundtrip_exact val_loss:(?P<val_loss>[0-9.]+) val_bpb:(?P<val_bpb>[0-9.]+)"
)
STEP_RE = re.compile(
    r"step:(?P<step>\d+)/(?P<total>\d+) val_loss:(?P<val_loss>[0-9.]+) val_bpb:(?P<val_bpb>[0-9.]+) "
    r"train_time:(?P<train_time>[0-9.]+)ms step_avg:(?P<step_avg>[0-9.]+)ms"
)
ARTIFACT_RE = re.compile(r"serialized_model_int8_zlib:(?P<bytes>\d+) bytes")


def parse_wave(wave_log: Path) -> list[dict[str, str]]:
    runs: list[dict[str, str]] = []
    by_label: dict[str, dict[str, str]] = {}
    for raw_line in wave_log.read_text().splitlines():
        line = raw_line.strip()
        if not line:
            continue
        start_match = START_RE.match(line)
        if start_match:
            entry = start_match.groupdict()
            by_label[entry["label"]] = entry
            runs.append(entry)
            continue
        end_match = END_RE.match(line)
        if end_match:
            entry = by_label.get(end_match.group("label"))
            if entry is not None:
                entry["status"] = end_match.group("status")
    return runs


def parse_run_log(run_log: Path) -> dict[str, str]:
    text = run_log.read_text()
    out: dict[str, str] = {}
    post_quant = POST_QUANT_RE.findall(text)
    if post_quant:
        val_loss, val_bpb = post_quant[-1]
        out["post_quant_val_loss"] = val_loss
        out["post_quant_val_bpb"] = val_bpb
    steps = STEP_RE.findall(text)
    if steps:
        step, total, val_loss, val_bpb, train_time, step_avg = steps[-1]
        out["step"] = f"{step}/{total}"
        out["val_loss"] = val_loss
        out["val_bpb"] = val_bpb
        out["train_time_ms"] = train_time
        out["step_avg_ms"] = step_avg
    artifacts = ARTIFACT_RE.findall(text)
    if artifacts:
        out["artifact_bytes"] = artifacts[-1]
    return out


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: summarize_local_wave.py <wave-log>", file=sys.stderr)
        return 1

    wave_log = Path(sys.argv[1]).resolve()
    if not wave_log.exists():
        print(f"Wave log not found: {wave_log}", file=sys.stderr)
        return 1

    runs = parse_wave(wave_log)
    stem = wave_log.stem
    run_tag = stem[:-5] if stem.endswith("_wave") else stem
    print(f"# Wave Summary: {wave_log.name}")
    print()
    print("| Label | Status | Step | Post-quant val_bpb | Step avg | Artifact bytes | Log |")
    print("|---|---:|---:|---:|---:|---:|---|")
    for run in runs:
        run_log = Path(run["dir"]) / "logs" / f"{run_tag}_{run['label']}.txt"
        fields: dict[str, str] = {}
        if run_log.exists():
            fields = parse_run_log(run_log)
        print(
            "| {label} | {status} | {step} | {post_quant_val_bpb} | {step_avg_ms}ms | {artifact_bytes} | `{log}` |".format(
                label=run["label"],
                status=run.get("status", "?"),
                step=fields.get("step", "?"),
                post_quant_val_bpb=fields.get("post_quant_val_bpb", fields.get("val_bpb", "?")),
                step_avg_ms=fields.get("step_avg_ms", "?"),
                artifact_bytes=fields.get("artifact_bytes", "?"),
                log=run_log,
            )
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
