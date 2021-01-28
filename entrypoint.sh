#!/bin/sh -l
set -euo pipefail

echo "setting prerequisites."
cd $GITHUB_WORKSPACE 
BUILD_META_DATA=$(gitversion | jq '.BuildMetaData')
NUGET_VERSION=$(gitversion | jq '.NuGetVersion')

VERSION_NUMBER=${NUGET_VERSION}.${BUILD_META_DATA}
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export BRANCH_NAME=$(echo ${GITHUB_REF#refs/heads/} | tr -d '[:punct:]')
echo "setting prerequisites done."
export VERSION_SUFFIX=$VERSION_NUMBER

echo "Print Branch name : $BRANCH_NAME"
echo "Print VERSION_SUFFIX: $VERSION_SUFFIX"

echo "Current directory : $GITHUB_WORKSPACE"

echo "Start: code build."
if [ -z "${INPUT_SRC_FILE_DIR_PATH}" ];
then
   echo "Running lazy build steps."
   cd $GITHUB_WORKSPACE && dotnet build --configuration Release

else
   echo "Running custom build steps."
   cd $INPUT_SRC_FILE_DIR_PATH  && dotnet build --configuration Release
fi

echo "Start: sonar scan."
if [ $INPUT_SONAR_SCAN_ENABLED == 'true' ]
then
    if [ -z "${INPUT_DOCKERFILE_DIR_PATH}" ];
    then
        echo "running lazy sonar tests."
         cd $GITHUB_WORKSPACE && dotnet test
        chmod +x /lazy-scripts/run_tests_sonarscan.sh && /lazy-scripts/run_tests_sonarscan.sh
    else
        cd $GITHUB_WORKSPACE && dotnet test
        chmod +x /lazy-scripts/scan.sh && /lazy-scripts/scan.sh -o ${INPUT_SONAR_ORG} -k ${INPUT_SONARCLOUD_PROJECT_KEY} -r ${GITHUB_SHA} -b ${BRANCH_NAME} ${INPUT_DOCKER_REPO_NAME} ${INPUT_DOCKER_IMAGE_NAME} sha-${GITHUB_SHA:0:7}
    fi
fi

echo "Start: Publish image to ECR."
echo "Ecr flag: $INPUT_DOCKER_PUSH"
if [ $INPUT_DOCKER_PUSH == 'true' ]
then
    if [ -z "${INPUT_DOCKERFILE_DIR_PATH}" ];
    then
        echo "Running lazy publish image."
        LAZY_DOCKERFILE_FULL_PATH=/lazy-scripts/Dockerfile
        chmod +x /lazy-scripts/publish.sh && /lazy-scripts/publish.sh ${ACCOUNT_ID} ${INPUT_DOCKER_REPO_NAME} ${INPUT_DOCKER_IMAGE_NAME} sha-${GITHUB_SHA:0:7} ${LAZY_DOCKERFILE_FULL_PATH}
    else
        echo "Running custom publish image"
        CUSTOM_DOCKERFILE=Dockerfile
        cd $INPUT_DOCKERFILE_DIR_PATH && chmod +x /lazy-scripts/publish.sh && /lazy-scripts/publish.sh ${ACCOUNT_ID} ${INPUT_DOCKER_REPO_NAME} ${INPUT_DOCKER_IMAGE_NAME} sha-${GITHUB_SHA:0:7} ${CUSTOM_DOCKERFILE}
    fi
fi

echo "Start: Publish nuget push."
echo "nugetflag: $INPUT_NUGET_PUSH"
if [ $INPUT_NUGET_PUSH == 'true' ]
then
    echo "Start publishing image to github registry."
    if [ -z "${INPUT_DOCKERFILE_DIR_PATH}" ];
    then
        echo "lazy flow" #todo
    else
        echo "custom nuget flow."
        cd $INPUT_DOCKERFILE_DIR_PATH  && docker build --build-arg GITHUB_USER --build-arg GITHUB_TOKEN --build-arg VERSION_SUFFIX --target publish-nuget-package --tag variant/dotnet-client .
        echo "Nuget image built , starting nuget image "
        export GITHUB_USER=$GITHUB_OWNER
        export GITHUB_TOKEN=$INPUT_GITHUB_OWNER_TOKEN
        cd $INPUT_DOCKERFILE_DIR_PATH  && docker run --rm -e GITHUB_USER -e GITHUB_TOKEN variant/dotnet-client:latest
                                        
    fi
fi



