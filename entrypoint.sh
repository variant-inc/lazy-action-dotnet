#!/bin/sh -l
set -euo pipefail

echo "setting prerequisites."
export BRANCH_NAME=$(echo ${GITHUB_REF#refs/heads/} | tr -d '[:punct:]')


if [ $BRANCH_NAME != 'master' ];
then 
    export VERSION_SUFFIX=$BRANCH_NAME.$GITHUB_RUN_NUMBER
else
    export VERSION_SUFFIX=$BRANCH_NAME.$GITHUB_RUN_NUMBER.1
fi

echo "Print Branch name : $BRANCH_NAME"
echo "Print VERSION_SUFFIX1: $VERSION_SUFFIX"

echo "Current directory : $GITHUB_WORKSPACE"

echo "Start: code build."
if [ -z "${CUSTOM_DOCKER_FILE_PATH}" ];
then
   echo "Running lazy build steps."
   cd $GITHUB_WORKSPACE && dotnet build --configuration Release
   echo "Start run tests."
   cd $GITHUB_WORKSPACE && dotnet test

else
   echo "Running custom build steps."
   chmod +x /lazy-scripts/build.sh && /lazy-scripts/build.sh ${DOCKER_REPO_NAME} ${DOCKER_IMAGE_NAME} sha-${GITHUB_SHA:0:7}
 
fi

echo "Start: sonar scan."
if [ $SONAR_SCAN_ENABLED == 'true' ]
then
    if [ -z "${CUSTOM_DOCKER_FILE_PATH}" ];
    then
        echo "running lazy sonar tests."
        chmod +x /lazy-scripts/run_tests_sonarscan.sh && /lazy-scripts/run_tests_sonarscan.sh
    else
        chmod +x /lazy-scripts/scan.sh && /lazy-scripts/scan.sh -o ${SONAR_ORG} -k ${SONARCLOUD_PROJECT_KEY} -r ${GITHUB_SHA} -b ${BRANCH_NAME} ${DOCKER_REPO_NAME} ${DOCKER_IMAGE_NAME} sha-${GITHUB_SHA:0:7}
    fi
fi

echo "Start: Publish image to ECR."
echo "Ecr flag: $DOCKER_PUSH"
if [ $DOCKER_PUSH == 'true' ]
then
    if [ -z "${CUSTOM_DOCKER_FILE_PATH}" ];
    then
        echo "Running lazy publish image."
        LAZY_DOCKERFILE_FULL_PATH=/lazy-scripts/Dockerfile
        chmod +x /lazy-scripts/publish.sh && /lazy-scripts/publish.sh ${DEV_AWS_ACCOUNT_ID} ${DOCKER_REPO_NAME} ${DOCKER_IMAGE_NAME} sha-${GITHUB_SHA:0:7} ${LAZY_DOCKERFILE_FULL_PATH}
    else
        echo "Running custom publish image"
        CUSTOM_DOCKERFILE=Dockerfile
        cd $CUSTOM_DOCKER_FILE_PATH && chmod +x /lazy-scripts/publish.sh && /lazy-scripts/publish.sh ${DEV_AWS_ACCOUNT_ID} ${DOCKER_REPO_NAME} ${DOCKER_IMAGE_NAME} sha-${GITHUB_SHA:0:7} ${CUSTOM_DOCKERFILE}
    fi
fi

echo "Start: Publish nuget push."
echo "nugetflag: $NUGET_PUSH"
if [ $NUGET_PUSH == 'true' ]
then
    echo "Start publishing image to github registry."
    if [ -z "${CUSTOM_DOCKER_FILE_PATH}" ];
    then
        echo "lazy flow"
    else
        echo "custom nuget flow."
        cd $CUSTOM_DOCKER_FILE_PATH  && docker build --build-arg GITHUB_USER --build-arg GITHUB_TOKEN --build-arg VERSION_SUFFIX --target publish-nuget-package --tag variant/schedule-adherence-client .
        echo "Nuget image built , starting nuget image "
        export GITHUB_TOKEN=$GITHUB_OWNER_TOKEN
        cd $CUSTOM_DOCKER_FILE_PATH  && docker run --rm -e GITHUB_USER -e GITHUB_TOKEN variant/schedule-adherence-client:latest
                                        
    fi
fi




