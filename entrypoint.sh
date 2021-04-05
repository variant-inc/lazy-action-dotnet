#!/bin/bash

set -eo

echo "Start: Setting Prerequisites"
cd "$GITHUB_WORKSPACE"
cd "$INPUT_SRC_FILE_DIR_PATH"
echo "Current directory: $(pwd)"

export AWS_WEB_IDENTITY_TOKEN_FILE="/token"
echo "$AWS_WEB_IDENTITY_TOKEN" >> "$AWS_WEB_IDENTITY_TOKEN_FILE"

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:=us-east-1}"

export BRANCH_NAME="$GITVERSION_BRANCHNAME"
echo "Print Branch name: $BRANCH_NAME"

export GITHUB_USER="$GITHUB_REPOSITORY_OWNER"

echo "End: Setting Prerequisites"

echo "Start: Sonar Scan"
sh -c "/scripts/coverage_scan.sh"
echo "End: Sonar Scan"

echo "Start: Trivy Scan"
sh -c "/scripts/trivy_scan.sh"
echo "End: Trivy Scan"

echo "Container Push: $INPUT_CONTAINER_PUSH_ENABLED"
if [ "$INPUT_CONTAINER_PUSH_ENABLED" = 'true' ]; then
  echo "Start: Publish Image to ECR"
  /scripts/publish.sh
  echo "End: Publish Image to ECR"
fi

echo "Nuget Publish: $INPUT_NUGET_PUSH_ENABLED"
if [ "$INPUT_NUGET_PUSH_ENABLED" = 'true' ]; then
  echo "Start: Publish Nuget Package"
  /scripts/nuget_push.sh
  echo "End: Publish Nuget Package"
fi
