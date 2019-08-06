#!/bin/sh

set -o nounset
set -o errexit
set -o pipefail

if [ $1 = "--version" ]; then
  echo 0.0.1
  exit 0
fi

ACME_CONFIG_ROOT=/etc/letsencrypt

echo "Syncing certbot configs from ${BUCKET_NAME}"
AWS_PROFILE=${BUCKET_PROFILE} aws s3 sync s3://${BUCKET_NAME} ${ACME_CONFIG_ROOT}

./rebuild-symlinks.py --log-level warning ${ACME_CONFIG_ROOT}

# shellcheck disable=SC2048
AWS_PROFILE=${DNS_PROFILE} certbot $*

echo "Syncing certbot configs to ${BUCKET_NAME}"
AWS_PROFILE=${BUCKET_PROFILE} aws s3 sync --delete ${ACME_CONFIG_ROOT} s3://${BUCKET_NAME}
