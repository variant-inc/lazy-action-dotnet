#!/bin/sh -l

set -euo pipefail

SONAR_ORGANIZATION=""
SONAR_PROJECT_KEY=""
REVISION=""
BRANCH_NAME=""
PULL_REQUEST_KEY=""

function process_cli
{
	local CURRENT=""

	while [ $# -gt 3 ]; do
		CURRENT=$1
		case $CURRENT in
			-o|--sonar-organization)
				SONAR_ORGANIZATION=$2
				shift 2
				;;
			-k|--sonar-project-key)
				SONAR_PROJECT_KEY=$2
				shift 2
				;;
			-r|--revision)
				REVISION=$2
				shift 2
				;;
			-b|--branch-name)
				BRANCH_NAME=$2
				shift 2
				;;
			-p|--pull-request-key)
				PULL_REQUEST_KEY=$2
				shift 2
				;;
			--)
				shift
				break
				;;
			*)
                echo "Unknown argument" 1>&2
				usage 3
				;;
		esac
	done

    DOCKER_REPO_NAME=${1}
    IMAGE_NAME=${2}
    IMAGE_TAG=${3}
}

process_cli $@

SONARSCAN_IMAGE=${DOCKER_REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}-sonarscan

function cleanup()
{
  set +euo pipefail
  docker image rm ${SONARSCAN_IMAGE}
}

trap "cleanup" EXIT

docker build --target sonarscan-env -t ${SONARSCAN_IMAGE} --build-arg "GITHUB_USER" --build-arg "GITHUB_TOKEN" .

if [ ! -z ${BRANCH_NAME} ]; then
    docker run --rm -e SONAR_TOKEN ${SONARSCAN_IMAGE} -d testresults -o ${SONAR_ORGANIZATION} -k ${SONAR_PROJECT_KEY} -r ${REVISION} -b ${BRANCH_NAME}
else
    docker run --rm -e SONAR_TOKEN ${SONARSCAN_IMAGE} -d testresults -o ${SONAR_ORGANIZATION} -k ${SONAR_PROJECT_KEY} -r ${REVISION} -p ${PULL_REQUEST_KEY}
fi
