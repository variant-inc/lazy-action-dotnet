#!/bin/sh -l

set -euo pipefail

if [ "$#" -ne 5 ]; then
    echo "Usage: ./publish.sh [AWS_ACCOUNT_ID] [REPO_NAME] [IMAGE_NAME] [IMAGE_TAG] [DOCKERFILE_FULL_PATH]"
    exit 1
fi

AWS_ACCOUNT_ID=${1}
DOCKER_REPO_NAME=${2}
IMAGE_NAME=${3}
IMAGE_TAG=${4}
DOCKER_REPO_HOST=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com
IMAGE=${DOCKER_REPO_HOST}/${DOCKER_REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}
DOCKERFILE_PATH=${5}

function cleanup()
{
  set +euo pipefail
  docker logout ${DOCKER_REPO_HOST}
  docker image rm ${IMAGE}
}

trap "cleanup" EXIT

echo "Connecting to AWS account."

aws ecr get-login-password | docker login -u AWS --password-stdin ${DOCKER_REPO_HOST}
docker build --build-arg "GITHUB_USER" --build-arg "GITHUB_TOKEN" -t ${IMAGE} -f $DOCKERFILE_PATH .

docker push ${IMAGE}
echo "::set-output name=image::${IMAGE}" 


