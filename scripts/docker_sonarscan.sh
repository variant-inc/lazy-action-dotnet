#!/bin/sh -l

set -ex

cleanup() {
  set +ex
  docker image rm sonarscan
}

trap "cleanup" EXIT

docker build --target "$INPUT_SONAR_SCAN_IN_DOCKER_TARGET" -t sonarscan --build-arg "GITHUB_USER" --build-arg "GITHUB_TOKEN" .
args="-e SONAR_TOKEN sonarscan -d testresults -o $SONAR_ORG -k $SONAR_PROJECT_KEY -r $GITHUB_SHA"
if [ -z "$PULL_REQUEST_KEY" ]; then
  docker run --rm "$args" -b "$BRANCH_NAME"
else
  docker run --rm "$args" -p "$PULL_REQUEST_KEY"
fi
