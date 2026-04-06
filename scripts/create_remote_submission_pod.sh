#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

POD_NAME="${POD_NAME:-parameter-golf-8xh100-submission}"
GPU_ID="${GPU_ID:-NVIDIA H100 80GB HBM3}"
GPU_COUNT="${GPU_COUNT:-8}"
CLOUD_TYPE="${CLOUD_TYPE:-SECURE}"
DATA_CENTER_IDS="${DATA_CENTER_IDS:-}"
IMAGE="${IMAGE:-runpod/parameter-golf:latest}"
CONTAINER_DISK_GB="${CONTAINER_DISK_GB:-50}"
VOLUME_GB="${VOLUME_GB:-50}"
VOLUME_MOUNT_PATH="${VOLUME_MOUNT_PATH:-/workspace}"
PORTS="${PORTS:-8888/http,3000/http,22/tcp}"
PUBLIC_KEY="${PUBLIC_KEY:-ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbOOdxMIFl+gfY9GnnnNNwIDgp8Snzlnz1wPCwQge5O wulfie.bain@outlook.com}"
JUPYTER_PASSWORD="${JUPYTER_PASSWORD:-parameter-golf}"

cmd=(
  runpodctl pod create
  --name="$POD_NAME"
  --image="$IMAGE"
  --gpu-id="$GPU_ID"
  --gpu-count="$GPU_COUNT"
  --cloud-type="$CLOUD_TYPE"
  --container-disk-in-gb="$CONTAINER_DISK_GB"
  --volume-in-gb="$VOLUME_GB"
  --volume-mount-path="$VOLUME_MOUNT_PATH"
  --ports="$PORTS"
  --env="{\"JUPYTER_PASSWORD\":\"$JUPYTER_PASSWORD\",\"PUBLIC_KEY\":\"$PUBLIC_KEY\"}"
)

if [[ -n "$DATA_CENTER_IDS" ]]; then
  cmd+=(--data-center-ids="$DATA_CENTER_IDS")
fi

printf 'Creating submission pod with command:\n'
printf ' %q' "${cmd[@]}"
printf '\n'

"${cmd[@]}"
