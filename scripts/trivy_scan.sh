#!/bin/bash

echo "Checking repo trivy folder exists."
IMAGE="$ECR_REGISTRY/$INPUT_ECR_REPOSITORY:$IMAGE_VERSION"

trivy $IMAGE

