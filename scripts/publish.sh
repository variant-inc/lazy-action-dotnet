#!/bin/sh -l

set -euo

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$INPUT_ECR_REPOSITORY_REGION.amazonaws.com"
IMAGE="$ECR_REGISTRY/$INPUT_ECR_REPOSITORY:$IMAGE_VERSION"

cleanup() {
  set +euo pipefail
  rm -rf publish
  docker logout "$ECR_REGISTRY"
  docker image rm "$IMAGE"
}

trap "cleanup" EXIT

echo "Connecting to AWS account."

aws ecr get-login-password | docker login -u AWS --password-stdin "$ECR_REGISTRY"

DOCKERFILE_PATH="$INPUT_DOCKERFILE_DIR_PATH"

mkdir -p /publish

if [ -z "$DOCKERFILE_PATH" ]; then
  echo "Running lazy publish image"
  DOCKERFILE_PATH=/docker/
  dotnet publish -c Release -o publish
fi

docker build --build-arg "$GITHUB_USER" --build-arg "$GITHUB_TOKEN" -t "$IMAGE" "$DOCKERFILE_PATH"
docker push "$IMAGE"
