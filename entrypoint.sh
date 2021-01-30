#!/bin/sh -l
set -euo pipefail

echo "Start: Setting Prerequisites"
cd $GITHUB_WORKSPACE
cd $INPUT_SRC_FILE_DIR_PATH
echo "Current directory: $(pwd)"

export BRANCH_NAME="$GITVERSION_BRANCHNAME"
echo "Print Branch name : $BRANCH_NAME"
echo "End: Setting Prerequisites"

if [ $INPUT_SONAR_SCAN_ENABLED == 'true' ]; then
  echo "Start: Sonar Scan"
  /scripts/coverage_scan.sh
  echo "End: Sonar Scan"
fi

if [ $INPUT_CONTAINER_PUSH_ENABLED == 'true' ]; then
  echo "Start: Publish Image to ECR"
  /scripts/publish.sh
  echo "End: Publish Image to ECR"
fi

echo "nugetflag: $INPUT_NUGET_PUSH"
if [ $INPUT_NUGET_PUSH == 'true' ]; then
  echo "Start: Publish Nuget Package"
  /scripts/nuget_push.sh
  echo "End: Publish Nuget Package"
fi
