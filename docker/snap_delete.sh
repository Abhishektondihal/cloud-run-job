#!/usr/bin/env bash
set -euo pipefail

# ======================
# Logging (Cloud Logging)
# ======================
log() {
  echo "{\"severity\":\"${1}\",\"message\":\"${*:2}\"}"
}

# ======================
# Configuration & Initialization
# ======================
readonly DAYS_THRESHOLD="${DAYS_THRESHOLD:-1}"
readonly PROJECT_IDS="${PROJECT_IDS:?PROJECT_IDS env var required}"
readonly GCS_BUCKET="${GCS_BUCKET:?GCS_BUCKET env var required}"
readonly JOB_NAME="${JOB_NAME:-snapshot-cleanup}"
readonly TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
readonly CSV_FILE="/tmp/deleted_snapshots_${TIMESTAMP}.csv"
readonly CUTOFF_DATE=$(date -d "$DAYS_THRESHOLD days ago" +%Y-%m-%d)
readonly TODAY_EPOCH=$(date +%s)
readonly GCS_PATH="gs://${GCS_BUCKET}/${JOB_NAME}/${TIMESTAMP}.csv"

# Initialize CSV
echo "Project,SnapshotName,AgeInDays,DeletedOn" > "$CSV_FILE"

log INFO "Snapshot cleanup job started"

# ======================
# Process snapshots
# ======================
TOTAL_DELETED=0

for PROJECT in $(echo "$PROJECT_IDS" | tr ',' '\n' | xargs -I {} sh -c 'echo "{}"'); do
  log INFO "Checking snapshots in project $PROJECT"

  # Query and process snapshots in one pass
  while IFS=$'\t' read -r SNAP_NAME CREATED_TS; do
    CREATED_EPOCH=$(date -d "$CREATED_TS" +%s)
    AGE_DAYS=$(( (TODAY_EPOCH - CREATED_EPOCH) / 86400 ))

    log INFO "Deleting snapshot $SNAP_NAME from $PROJECT (age: ${AGE_DAYS} days)"
    
    if gcloud compute snapshots delete "$SNAP_NAME" \
      --project="$PROJECT" \
      --quiet 2>/dev/null; then
      echo "$PROJECT,$SNAP_NAME,$AGE_DAYS,$(date -Iseconds)" >> "$CSV_FILE"
      ((TOTAL_DELETED++))
    else
      log ERROR "Failed to delete snapshot $SNAP_NAME from $PROJECT"
    fi
  done < <(gcloud compute snapshots list \
    --project="$PROJECT" \
    --filter="creationTimestamp.date('%Y-%m-%d') < '$CUTOFF_DATE'" \
    --format="value(name,creationTimestamp)" 2>/dev/null || true)
done

# ======================
# Upload report & finalize
# ======================
log INFO "Uploading report to $GCS_PATH (total deleted: $TOTAL_DELETED)"
gsutil cp "$CSV_FILE" "$GCS_PATH" 2>/dev/null || log ERROR "Failed to upload CSV to GCS"

log INFO "Snapshot cleanup completed successfully"
