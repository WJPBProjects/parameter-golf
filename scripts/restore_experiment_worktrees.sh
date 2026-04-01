#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo_name="$(basename "$repo_root")"
parent_dir="$(cd "$repo_root/.." && pwd)"
worktrees_root="$parent_dir/${repo_name}-worktrees"

default_experiments=(
  xsa-all
  leakyrelu-slope-sweep
  pr824-mimic-gatedattn-valueresid
  gptq-self-calibration
  selective-post-gptq-pruning
  rope-lnscale-grid
  splineconv-hybrid
  compile-safe-late-qat
)

if [[ $# -gt 0 ]]; then
  experiments=("$@")
else
  experiments=("${default_experiments[@]}")
fi

mkdir -p "$worktrees_root"

git -C "$repo_root" fetch origin 'refs/heads/codex/*:refs/remotes/origin/codex/*'

link_if_missing() {
  local src="$1"
  local dst="$2"
  if [[ -e "$src" && ! -e "$dst" ]]; then
    ln -s "$src" "$dst"
  fi
}

for name_raw in "${experiments[@]}"; do
  name="$(printf '%s' "$name_raw" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-')"
  branch="codex/${name}"
  remote_ref="origin/${branch}"
  worktree_path="$worktrees_root/$name"

  echo
  echo "==> Restoring $branch"

  if ! git -C "$repo_root" rev-parse --verify "$remote_ref" >/dev/null 2>&1; then
    echo "Missing remote ref: $remote_ref" >&2
    continue
  fi

  if [[ -e "$worktree_path" ]]; then
    echo "Worktree already present: $worktree_path"
  else
    if git -C "$repo_root" rev-parse --verify "$branch" >/dev/null 2>&1; then
      git -C "$repo_root" worktree add "$worktree_path" "$branch"
    else
      git -C "$repo_root" worktree add -b "$branch" "$worktree_path" "$remote_ref"
    fi
  fi

  mkdir -p "$worktree_path/data"
  mkdir -p "$worktree_path/codex_notes"

  link_if_missing "$repo_root/.venv" "$worktree_path/.venv"
  link_if_missing "$repo_root/.uv-cache" "$worktree_path/.uv-cache"
  link_if_missing "$repo_root/data/datasets" "$worktree_path/data/datasets"
  link_if_missing "$repo_root/data/tokenizers" "$worktree_path/data/tokenizers"

  ln -sfn "$repo_root/codex_notes/coordination" "$worktree_path/codex_notes/coordination_live"

  exclude_file="$(git -C "$worktree_path" rev-parse --git-path info/exclude)"
  mkdir -p "$(dirname "$exclude_file")"
  touch "$exclude_file"
  for pattern in ".uv-cache" "codex_notes/coordination_live"; do
    if ! grep -qxF "$pattern" "$exclude_file"; then
      printf '%s\n' "$pattern" >> "$exclude_file"
    fi
  done

  echo "Ready: $worktree_path"
done

echo
echo "Done."
