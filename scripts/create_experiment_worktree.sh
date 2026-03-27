#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <experiment-name> [base-ref]" >&2
  exit 1
fi

name_raw="$1"
base_ref="${2:-HEAD}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo_name="$(basename "$repo_root")"
parent_dir="$(cd "$repo_root/.." && pwd)"
worktrees_root="$parent_dir/${repo_name}-worktrees"
name="$(printf '%s' "$name_raw" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-')"
branch="codex/${name}"
worktree_path="$worktrees_root/$name"

mkdir -p "$worktrees_root"

if ! git -C "$repo_root" rev-parse --verify "$base_ref" >/dev/null 2>&1; then
  echo "Base ref '$base_ref' does not exist." >&2
  exit 1
fi

if git -C "$repo_root" rev-parse --verify "$branch" >/dev/null 2>&1; then
  echo "Branch '$branch' already exists." >&2
  exit 1
fi

if [[ -e "$worktree_path" ]]; then
  echo "Worktree path already exists: $worktree_path" >&2
  exit 1
fi

dirty_status="$(git -C "$repo_root" status --porcelain)"
if [[ -n "$dirty_status" ]]; then
  cat >&2 <<EOF
Warning: the main worktree has uncommitted changes.
These changes are NOT copied into the new experiment worktree unless you first commit them
or choose a base ref that already contains them.
EOF
fi

git -C "$repo_root" worktree add -b "$branch" "$worktree_path" "$base_ref"

link_if_missing() {
  local src="$1"
  local dst="$2"
  if [[ -e "$src" && ! -e "$dst" ]]; then
    ln -s "$src" "$dst"
  fi
}

mkdir -p "$worktree_path/data"
mkdir -p "$worktree_path/experiments/$name"

# Shared mutable or heavy local resources that should not be recopied per experiment.
link_if_missing "$repo_root/.venv" "$worktree_path/.venv"
link_if_missing "$repo_root/.uv-cache" "$worktree_path/.uv-cache"
link_if_missing "$repo_root/codex_notes" "$worktree_path/codex_notes"
link_if_missing "$repo_root/data/datasets" "$worktree_path/data/datasets"
link_if_missing "$repo_root/data/tokenizers" "$worktree_path/data/tokenizers"

# Give each experiment its own trainer entrypoints so code changes can stay isolated
# in branch-local files instead of constantly colliding on the repo-root trainers.
cp "$worktree_path/train_gpt.py" "$worktree_path/experiments/$name/train_gpt.py"
cp "$worktree_path/train_gpt_mlx.py" "$worktree_path/experiments/$name/train_gpt_mlx.py"
cat > "$worktree_path/experiments/$name/README.md" <<EOF
# Experiment: $name

This folder contains the experiment-local trainer copies for \`$branch\`.

Preferred files to edit:

- \`experiments/$name/train_gpt.py\`
- \`experiments/$name/train_gpt_mlx.py\`

Suggested local-screen command:

\`\`\`bash
TRAIN_MLX_SCRIPT=experiments/$name/train_gpt_mlx.py bash scripts/run_local_screen_mlx.sh
\`\`\`

Suggested direct MLX command:

\`\`\`bash
RUN_ID=${name}_mlx ./.venv/bin/python experiments/$name/train_gpt_mlx.py
\`\`\`
EOF

# Shared coordination should always point back to the main worktree so experiment
# branches can report status without merging their code into main.
mkdir -p "$worktree_path/codex_notes"
ln -sfn "$repo_root/codex_notes/coordination" "$worktree_path/codex_notes/coordination_live"

exclude_file="$(git -C "$worktree_path" rev-parse --git-path info/exclude)"
mkdir -p "$(dirname "$exclude_file")"
touch "$exclude_file"
for pattern in ".uv-cache" "codex_notes/coordination_live"; do
  if ! grep -qxF "$pattern" "$exclude_file"; then
    printf '%s\n' "$pattern" >> "$exclude_file"
  fi
done

cat <<EOF
Created experiment worktree.

  Branch:   $branch
  Base ref: $base_ref
  Path:     $worktree_path

Next steps:
  cd "$worktree_path"
  git status
  source .venv/bin/activate
  TRAIN_MLX_SCRIPT="experiments/$name/train_gpt_mlx.py" bash scripts/run_local_screen_mlx.sh
EOF
