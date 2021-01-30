#!/bin/sh -l

set -euo

pull_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
export PULL_REQUEST_KEY=$pull_number

if [ -z "${INPUT_DOCKERFILE_DIR_PATH}" ]; then
  echo "running lazy sonar tests."
  /scripts/sonarscan.sh
else
  /scripts/docker_sonarscan.sh
fi
