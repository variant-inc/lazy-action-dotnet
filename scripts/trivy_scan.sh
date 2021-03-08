#!/bin/bash

echo "Checking repo trivy folder exists."
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
IMAGE="$ECR_REGISTRY/$INPUT_ECR_REPOSITORY:$IMAGE_VERSION"

trivy $IMAGE

