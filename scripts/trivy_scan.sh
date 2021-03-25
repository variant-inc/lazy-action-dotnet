#!/bin/bash

echo "Checking repo trivy folder exists."
set -e

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
IMAGE="$ECR_REGISTRY/$INPUT_ECR_REPOSITORY:$IMAGE_VERSION"

# trivy $IMAGE
echo "Download trivy file from s3." 
aws s3 cp s3://trivy-root/.trivyignore .

if [ -d "$GITHUB_WORKSPACE/trivy" ] 
then
    echo "Directory trivy exists." 
    cat $GITHUB_WORKSPACE/trivy/.trivyignore >> .trivyignore
else
    echo "Directory $GITHUB_WORKSPACE/trivy does not exists."
fi

docker login -u AWS -p $(aws ecr-public get-login-password --region us-east-1) $ECR_REGISTRY
docker pull  064859874041.dkr.ecr.us-east-1.amazonaws.com/mobile/driver-status-worker:1.0.0-54

trivy 064859874041.dkr.ecr.us-east-1.amazonaws.com/mobile/driver-status-worker:1.0.0-54

# trivy $IMAGE

