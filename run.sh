#!/bin/sh
set -e

: "${S3_STORAGE_TIER:=STANDARD_IA}"

# Hide Terminus update messages
export TERMINUS_HIDE_UPDATE_MESSAGES="1"

# Login via Terminus
echo "Authenticating with Pantheon via a Terminus machine token"
terminus auth:login --machine-token="$TERMINUS_MACHINE_TOKEN"

# Just in case the $PANTHEON_SITE_ID is a UUID instead of a name
pantheon_site_name=$(terminus site:info "$PANTHEON_SITE_ID" --format json | jq -r '.name')
timestamp=$(date --iso-8601=seconds | tr -d ':-' | cut -c1-15)
if [ "$TERMINUS_BACKUP_ELEMENT" = "db" ]; then
  filename="${pantheon_site_name}-db-${timestamp}.sql.gz"
else
  filename="${pantheon_site_name}-${TERMINUS_BACKUP_ELEMENT}-${timestamp}.tar.gz"
fi
destination="/data/$filename"
s3_url="s3://${S3_BUCKET}/${S3_PREFIX}${PANTHEON_SITE_ID}/${TERMINUS_BACKUP_ELEMENT}/${FILENAME_PREFIX}${filename}"

# Export the backup
echo "About to export the latest '$TERMINUS_BACKUP_ELEMENT' backup from Pantheon to $destination"
terminus backup:get --element="$TERMINUS_BACKUP_ELEMENT" --to="$destination" "$PANTHEON_SITE_ID.$PANTHEON_SITE_ENV"
echo "Export to $destination completed"

# Publish to S3
echo "About to upload $destination to $s3_url"
aws s3 cp "$destination" "$s3_url" --storage-class "$S3_STORAGE_TIER" --metadata "PantheonSiteId=${PANTHEON_SITE_ID},PantheonSiteEnv=${PANTHEON_SITE_ENV}"
echo "Upload to $s3_url completed"
