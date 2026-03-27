#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <experiment-name-or-branch>" >&2
  exit 1
fi

target="$1"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo_name="$(basename "$repo_root")"
parent_dir="$(cd "$repo_root/.." && pwd)"
worktrees_root="$parent_dir/${repo_name}-worktrees"

branch="$target"
if [[ "$branch" != codex/* ]]; then
  branch="codex/${branch}"
fi

name="${branch#codex/}"
worktree_path="$worktrees_root/$name"

if [[ ! -d "$worktree_path" ]]; then
  echo "Worktree path not found: $worktree_path" >&2
  exit 1
fi

git -C "$repo_root" worktree remove "$worktree_path"
if git -C "$repo_root" rev-parse --verify "$branch" >/dev/null 2>&1; then
  git -C "$repo_root" branch -D "$branch"
fi

cat <<EOF
Removed experiment worktree.

  Branch: $branch
  Path:   $worktree_path
EOF
