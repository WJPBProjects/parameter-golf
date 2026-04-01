#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export VARIANT="${VARIANT:-sp1024}"
export TRAIN_SHARDS="${TRAIN_SHARDS:-50}"

exec ./.venv/bin/python data/cached_challenge_fineweb.py --variant "$VARIANT" --train-shards "$TRAIN_SHARDS"
