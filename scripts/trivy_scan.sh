#!/bin/bash

echo "Checking repo trivy folder exists."
set -e

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
IMAGE="$ECR_REGISTRY/$INPUT_ECR_REPOSITORY:$IMAGE_VERSION"

aws s3 cp s3://trivy-root/.trivyignore .trivyignore

if [ -d "$GITHUB_WORKSPACE/trivy" ] 
then
    echo "Directory trivy exists." 
    cat $GITHUB_WORKSPACE/trivy/.trivyignore >> .trivyignore
else
    echo "Error: Directory $GITHUB_WORKSPACE/trivy does not exists."
fi


trivy $IMAGE

