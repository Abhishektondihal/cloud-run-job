#!/bin/bash
set -euo pipefail

echo "Starting Snapshot Cleanup Cloud Run Job..."

if /scripts/snap_delete.sh; then
  echo "Snapshot Cleanup Job completed successfully"
  exit 0
else
  echo "Snapshot Cleanup Job failed with exit code $?"
  exit 1
fi
