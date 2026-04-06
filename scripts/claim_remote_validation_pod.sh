#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OWNER_LABEL="${1:-main-agent}"
CLAIMS_DIR="${CLAIMS_DIR:-$ROOT/codex_notes/coordination_live/remote_pod_claims}"
CLAIM_TIMEOUT_SECONDS="${CLAIM_TIMEOUT_SECONDS:-300}"
CLAIM_POLL_SECONDS="${CLAIM_POLL_SECONDS:-5}"

mkdir -p "$CLAIMS_DIR"

if resolved_key="$(bash "$ROOT/scripts/resolve_runpod_ssh_key.sh" 2>/dev/null)"; then
  SSH_READY_OPTS=(-i "$resolved_key" -o StrictHostKeyChecking=accept-new -o BatchMode=yes)
else
  SSH_READY_OPTS=(-o StrictHostKeyChecking=accept-new -o BatchMode=yes)
fi

ssh_ready() {
  local ip="$1"
  local port="$2"
  ssh "${SSH_READY_OPTS[@]}" -p "$port" "root@$ip" 'exit 0' >/dev/null 2>&1 || return 1
  sleep 2
  ssh "${SSH_READY_OPTS[@]}" -p "$port" "root@$ip" 'exit 0' >/dev/null 2>&1
}

POD_IDS=(
  "untjvs1cx2gq4u"
  "2ollt57dzbud46"
  "94x77u15s3v7s2"
)

cleanup_claim() {
  local claim_dir="$1"
  rm -rf "$claim_dir"
}

for pod_id in "${POD_IDS[@]}"; do
  claim_dir="$CLAIMS_DIR/$pod_id"
  if [[ -d "$claim_dir" ]]; then
    continue
  fi

  pod_json="$(runpodctl pod get "$pod_id")"
  desired_status="$(printf '%s' "$pod_json" | jq -r '.desiredStatus // .status // ""')"
  pod_name="$(printf '%s' "$pod_json" | jq -r '.name // ""')"

  # Guard rail: never reuse a pod that is already running or in a non-stopped state.
  if [[ "$desired_status" != "EXITED" ]]; then
    continue
  fi

  if ! mkdir "$claim_dir" 2>/dev/null; then
    continue
  fi

  cat >"$claim_dir/claim.meta.txt" <<EOF
pod_id=$pod_id
pod_name=$pod_name
owner=$OWNER_LABEL
claimed_at_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)
cwd=$ROOT
EOF

  if ! start_output="$(runpodctl pod start "$pod_id" 2>&1)"; then
    printf '%s\n' "$start_output" >"$claim_dir/start.error.txt"
    cleanup_claim "$claim_dir"
    continue
  fi
  printf '%s\n' "$start_output" >"$claim_dir/start.output.txt"

  deadline=$(( $(date +%s) + CLAIM_TIMEOUT_SECONDS ))
  while (( $(date +%s) < deadline )); do
    ssh_info="$(runpodctl ssh info "$pod_id" 2>/dev/null || true)"
    if [[ -n "$ssh_info" ]] && printf '%s' "$ssh_info" | jq -e '.ssh_command? and .ip? and .port?' >/dev/null 2>&1; then
      ip="$(printf '%s' "$ssh_info" | jq -r '.ip')"
      port="$(printf '%s' "$ssh_info" | jq -r '.port')"
      if ssh_ready "$ip" "$port"; then
        printf '%s\n' "$pod_json" >"$claim_dir/pod.get.json"
        printf '%s\n' "$ssh_info" >"$claim_dir/ssh.info.json"
        printf '%s\n' "$ssh_info"
        exit 0
      fi
    fi
    printf '%s\n' "$ssh_info" >"$claim_dir/ssh.info.last.json"
    sleep "$CLAIM_POLL_SECONDS"
  done

  printf 'timeout waiting for ssh info for pod %s\n' "$pod_id" >"$claim_dir/start.error.txt"
  runpodctl pod stop "$pod_id" >/dev/null 2>&1 || true
  cleanup_claim "$claim_dir"
done

echo '{"error":"no stopped unlocked validation pod could be claimed"}' >&2
exit 1
