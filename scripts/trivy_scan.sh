#!/bin/bash

echo "Checking repo trivy folder exists."
set -e

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
IMAGE="$ECR_REGISTRY/$INPUT_ECR_REPOSITORY:$IMAGE_VERSION"
S3_BUCKET_NAME=trivy-ops

credentials=$(aws sts assume-role --role-arn arn:aws:iam::108141096600:role/ops-github-runner --role-session-name ops-s3)

export AWS_PAGER=""
aws configure set aws_access_key_id $(echo "$credentials" | jq -r '.Credentials.AccessKeyId') --profile ops
aws configure set aws_secret_access_key $(echo "$credentials" | jq -r '.Credentials.SecretAccessKey') --profile ops
aws configure set aws_session_token $(echo "$credentials" | jq -r '.Credentials.SessionToken') --profile ops

echo "Print repo name: $GITHUB_REPOSITORY"
echo "Download trivy file from s3." 
aws --profile ops s3 cp s3://${S3_BUCKET_NAME}/.trivyignore .

PATH_TO_FOLDER=$GITHUB_REPOSITORY
totalFoundObjects=$(aws s3 --profile ops ls s3://${S3_BUCKET_NAME}/${PATH_TO_FOLDER}/.trivyignore --recursive --summarize | grep "Total Objects: " | sed 's/[^0-9]*//g')
if [ "$totalFoundObjects" -eq "0" ]; then
   echo "There are no repo files found"
else
  echo "Repo file found $totalFoundObjects"
  mkdir trivy
  cd trivy && aws --profile ops s3 cp s3://${S3_BUCKET_NAME}/${PATH_TO_FOLDER}/.trivyignore .
  cat $GITHUB_WORKSPACE/trivy/.trivyignore >> .trivyignore
fi

cat .trivyignore

trivy --severity=CRITICAL,HIGH,MEDIUM --exit-code 1 $IMAGE


