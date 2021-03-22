#!/bin/bash

set -e

cleanup() {
  set +ex
  docker image rm sonarscan
}

trap "cleanup" EXIT
eval "docker build --target $INPUT_SONAR_SCAN_IN_DOCKER_TARGET -t sonarscan . $(for i in $(env); do out+="--build-arg $i "; done; echo "$out")"
args=("-d testresults" "-o $SONAR_ORG" "-k $SONAR_PROJECT_KEY" "-r $GITHUB_SHA")
if [ "$PULL_REQUEST_KEY" = null ]; then
    args+=("-b $BRANCH_NAME")
else
    args+=("-p $PULL_REQUEST_KEY")
fi

docker run --rm -e SONAR_TOKEN sonarscan "${args[@]}"
