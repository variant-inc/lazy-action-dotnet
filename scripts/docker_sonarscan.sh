#!/bin/sh -l

set -euo pipefail

function cleanup() {
  set +euo pipefail
  docker image rm sonar
}

trap "cleanup" EXIT

docker build --target sonarscan-env -t ${SONARSCAN_IMAGE} --build-arg "GITHUB_USER" --build-arg "GITHUB_TOKEN" .
args="-e SONAR_TOKEN ${SONARSCAN_IMAGE} -d testresults -o ${SONAR_ORG} -k ${SONAR_PROJECT_KEY} -r ${GITHUB_SHA}"
if [ -z ${PULL_REQUEST_KEY} ]; then
  docker run --rm $args -b ${BRANCH_NAME}
else
  docker run --rm $args -p ${PULL_REQUEST_KEY}
fi
