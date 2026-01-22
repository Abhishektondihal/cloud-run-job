#!/bin/bash
set -e

echo "Starting Snapshot Cleanup Cloud Run Job..."
/scripts/snap_delete.sh
echo "Snapshot Cleanup Job completed"
