#!/bin/sh -l
set -euo pipefail

if [ "$#" -ne 3 ]; then
    echo "Usage: ./build.sh [REPO_NAME] [IMAGE_NAME] [IMAGE_TAG]"
    exit 1
fi

DOCKER_REPO_NAME=${1}
IMAGE_NAME=${2}
IMAGE_TAG=${3}
IMAGE=${DOCKER_REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}

function cleanup()
{
  set +euo pipefail
  docker image rm ${IMAGE}
}

trap "cleanup" EXIT

docker build -t ${IMAGE} --build-arg "GITHUB_USER" --build-arg "GITHUB_TOKEN" .
echo "::set-output name=image::${IMAGE}"