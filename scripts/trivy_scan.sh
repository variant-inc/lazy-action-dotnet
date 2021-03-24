#!/bin/bash

echo "Checking repo trivy folder exists."
set -e

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
IMAGE="$ECR_REGISTRY/$INPUT_ECR_REPOSITORY:$IMAGE_VERSION"

# trivy $IMAGE

docker pull 064859874041.dkr.ecr.us-east-1.amazonaws.com/mobile/driver-status-worker:1.0.0-54
trivy 064859874041.dkr.ecr.us-east-1.amazonaws.com/mobile/driver-status-worker:1.0.0-54

