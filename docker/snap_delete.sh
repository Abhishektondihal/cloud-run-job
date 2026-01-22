#!/usr/bin/env bash
set -euo pipefail
 
# ======================
# Logging (Cloud Logging)
# ======================
log() {
  local severity="$1"; shift
  echo "{\"severity\":\"$severity\",\"message\":\"$*\"}"
}
 
# ======================
# Config
# ======================
DAYS_THRESHOLD="${DAYS_THRESHOLD:-427}"
PROJECT_IDS="${PROJECT_IDS:?PROJECT_IDS env var required}"
GCS_BUCKET="${GCS_BUCKET:?GCS_BUCKET env var required}"
JOB_NAME="${JOB_NAME:-snapshot-cleanup}"
 
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
CSV_FILE="/tmp/deleted_snapshots_${TIMESTAMP}.csv"
 
IFS=',' read -ra PROJECTS <<< "$PROJECT_IDS"
 
TODAY_EPOCH=$(date +%s)
CUTOFF_DATE=$(date -d "$DAYS_THRESHOLD days ago" +%Y-%m-%d)
 
echo "Project,SnapshotName,AgeInDays,DeletedOn" > "$CSV_FILE"
 
declare -A PROJECT_SNAPSHOTS
 
log INFO "Snapshot cleanup job started"
 
# ======================
# Collect snapshots
# ======================
for PROJECT in "${PROJECTS[@]}"; do
  PROJECT=$(echo "$PROJECT" | xargs)
  log INFO "Checking snapshots in project $PROJECT"
 
  SNAPSHOTS=$(gcloud compute snapshots list \
    --project="$PROJECT" \
    --filter="creationTimestamp.date('%Y-%m-%d') < '$CUTOFF_DATE'" \
    --format="value(name,creationTimestamp)" 2>/dev/null || true)
 
  [[ -z "$SNAPSHOTS" ]] && log INFO "No old snapshots in $PROJECT" && continue
 
  while read -r NAME TS; do
    CREATED_EPOCH=$(date -d "$TS" +%s)
    AGE_DAYS=$(( (TODAY_EPOCH - CREATED_EPOCH) / 86400 ))
    PROJECT_SNAPSHOTS["$PROJECT"]+="$NAME:$AGE_DAYS"$'\n'
  done <<< "$SNAPSHOTS"
done
 
[[ ${#PROJECT_SNAPSHOTS[@]} -eq 0 ]] && log INFO "No snapshots eligible for deletion" && exit 0
 
# ======================
# Delete snapshots
# ======================
for PROJECT in "${!PROJECT_SNAPSHOTS[@]}"; do
  while IFS=":" read -r SNAP_NAME SNAP_AGE; do
    log INFO "Deleting snapshot $SNAP_NAME from $PROJECT"
    gcloud compute snapshots delete "$SNAP_NAME" \
      --project="$PROJECT" \
      --quiet
 
    echo "$PROJECT,$SNAP_NAME,$SNAP_AGE,$(date -Iseconds)" >> "$CSV_FILE"
  done <<< "${PROJECT_SNAPSHOTS[$PROJECT]}"
done
 
# ======================
# Upload CSV to GCS
# ======================
GCS_PATH="gs://${GCS_BUCKET}/${JOB_NAME}/${TIMESTAMP}.csv"
log INFO "Uploading report to $GCS_PATH"
gsutil cp "$CSV_FILE" "$GCS_PATH"
 
log INFO "Snapshot cleanup completed successfully"