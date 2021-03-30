#!/bin/bash

echo "Checking repo trivy folder exists."
set -e

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
IMAGE="$ECR_REGISTRY/$INPUT_ECR_REPOSITORY:$IMAGE_VERSION"

credentials=$(aws sts assume-role --role-arn arn:aws:iam::108141096600:role/ops-github-runner --role-session-name ops-s3)

export AWS_PAGER=""
aws configure set aws_access_key_id $(echo "$credentials" | jq -r '.Credentials.AccessKeyId') --profile ops
aws configure set aws_secret_access_key $(echo "$credentials" | jq -r '.Credentials.SecretAccessKey') --profile ops
aws configure set aws_session_token $(echo "$credentials" | jq -r '.Credentials.SessionToken') --profile ops

echo "Download trivy file from s3." 
aws s3 cp s3://trivy-ops/.trivyignore .

echo "Print repo name: $GITHUB_REPOSITORY"

if [[ ! -z $(aws s3api list-buckets --query 'Buckets[?Name==`'$GITHUB_REPOSITORY'`]' --output text) ]]; 
then
  echo "Repo bucket exists."
   mkdir trivy
   cd trivy && aws s3 cp s3://$GITHUB_REPOSITORY/.trivyignore .
   cat $GITHUB_WORKSPACE/trivy/.trivyignore >> .trivyignore
else
  echo "Repo bucket does not exists."
fi

cat .trivyignore
# if [ -d "$GITHUB_WORKSPACE/trivy" ] 
# then
#     echo "Directory trivy exists." 
#     cat $GITHUB_WORKSPACE/trivy/.trivyignore >> .trivyignore
# else
#     echo "Directory $GITHUB_WORKSPACE/trivy does not exists."
# fi

trivy --severity=CRITICAL,HIGH,MEDIUM --exit-code 1 $IMAGE


