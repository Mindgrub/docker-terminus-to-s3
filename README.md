# docker-terminus-to-s3

An Ubuntu-based Docker image for [downloading a backup from Pantheon](https://pantheon.io/docs/terminus/commands/backup-get) and uploading it to Amazon S3.

## Environment Variables

- `TERMINUS_MACHINE_TOKEN` – Required. The machine token that `terminus` can use to authenticate.
- `TERMINUS_BACKUP_ELEMENT` - Required. The backup to retrieve; this _must_ be either `db` or `files`.
- `PANTHEON_SITE_ID` – Required. The Pantheon site UUID.
- `PANTHEON_SITE_ENV` – Required. The Pantheon site environment (e.g. `live`).
- `S3_BUCKET` – Required. The S3 bucket name used to store the exported file.
- `S3_PREFIX` – Optional. A string to prepend to the S3 object key (Default: "").
- `FILENAME_PREFIX` – Optional. A string to prepend to the exported file (Default: "").
- `S3_STORAGE_TIER` – Optional. The storage tier to use with S3 (Default: "STANDARD_IA").

### AWS Permissions

If this Docker image is used within Amazon ECS, specify permissions to S3 within your Task Definition role. Otherwise, you can provide `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as environment variables.

## Technical Details

The pattern for the final S3 object URL is: `s3://${S3_BUCKET}/${S3_PREFIX}${PANTHEON_SITE_ID}/${TERMINUS_BACKUP_ELEMENT}/${FILENAME_PREFIX}${filename}`.

Depending on the value of `$TERMINUS_BACKUP_ELEMENT`, the `$filename` variable will be `${pantheon_site_name}-db-${timestamp}.sql.gz` or `${pantheon_site_name}-files-${timestamp}.tar.gz`. The `$pantheon_site_name` variable is the "name" of the Pantheon site (as opposed to the UUID). The `$timestamp` variable is an ISO 8601 date and time with symbols removed (e.g. _20220202T160142_).
