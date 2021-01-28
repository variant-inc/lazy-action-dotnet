#!/bin/sh -l

set -eu
CMDNAME=$(basename "$0")

OUTPUTDIR=""
SONAR_ORGANIZATION=""
SONAR_PROJECT_KEY=""
REVISION=""
BRANCH_NAME=""
PULL_REQUEST_KEY=""

function usage
{
  local exitcode=$1
  cat << EOF >&2
Usage:
  $CMDNAME --output-dir --sonar-organization --sonar-project-key --revision {--branch-name|--pull-request-key} [--help]
  --help                      Show this message and exit
  -d, --output-dir            (Required) Output directory of coverage files
  -o, --sonar-organization    (Required) Sonarcloud organization
  -k, --sonar-project-key     (Required) Project key of the sonarcloud project to record against
  -r, --revision              (Required) SHA of the commit being analyzed to enable PR/commit annotations.
  -b, --branch-name           Branch name to associate results. Cannot be used with --pull-request-key
  -p, --pull-request-key      Pull request key to associate results. Cannot be used with --branch-name
    The environment variable SONAR_TOKEN is used for the sonar.login property
EOF

  exit "$exitcode"
}

function process_cli
{
  local CURRENT=""

  while [ $# -gt 0 ]; do
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
      -d|--output-dir)
        OUTPUTDIR=$2
        shift 2
        ;;
      --help)
        usage 0
        ;;
      *)
                echo "Unknown argument" 1>&2
        usage 3
        ;;
    esac
  done
}

process_cli $@

if [ ! -z ${BRANCH_NAME} ] && [ ! -z ${PULL_REQUEST_KEY} ]; then
    echo "Cannot specify both --branch-name and --pull-request-key" 1>&2
    exit 1
elif [ -z ${BRANCH_NAME} ] && [ -z ${PULL_REQUEST_KEY} ]; then
    echo "Must specify one of --branch-name and --pull-request-key" 1>&2
    exit 1
fi

if [ -z ${SONAR_PROJECT_KEY} ] || [ -z ${SONAR_ORGANIZATION} ] || [ -z ${OUTPUTDIR} ] || [ -z ${REVISION} ]; then
    echo "Missing required argument" 1>&2
    usage 1
fi

function sonar_logout()
{
  set +eu
  dotnet sonarscanner end /d:sonar.login=${SONAR_TOKEN}
}

if [ ! -z ${BRANCH_NAME} ]; then
    dotnet sonarscanner begin \
      /o:${SONAR_ORGANIZATION} \
      /k:${SONAR_PROJECT_KEY} \
      /d:sonar.host.url="https://sonarcloud.io" \
      /d:sonar.login=${SONAR_TOKEN} \
      /d:sonar.cs.opencover.reportsPaths=**/coverage.opencover.xml \
      /d:sonar.exclusions=**/*Migrations/**/* \
      /d:sonar.scm.disabled=true \
      /d:sonar.scm.revision=${REVISION} \
      /d:sonar.branch.name=${BRANCH_NAME}
else
    dotnet sonarscanner begin \
      /o:${SONAR_ORGANIZATION} \
      /k:${SONAR_PROJECT_KEY} \
      /d:sonar.host.url="https://sonarcloud.io" \
      /d:sonar.login=${SONAR_TOKEN} \
      /d:sonar.cs.opencover.reportsPaths=**/coverage.opencover.xml \
      /d:sonar.exclusions=**/*Migrations/**/* \
      /d:sonar.scm.disabled=true \
      /d:sonar.scm.revision=${REVISION} \
      /d:sonar.pullrequest.key=${PULL_REQUEST_KEY}
fi

trap "sonar_logout" EXIT

# unset to allow dotnet test to return with nonzero exit code
set +e
dotnet test \
  /p:CollectCoverage=true \
  /p:CoverletOutput=${OUTPUTDIR}/coverage.opencover.xml \
  /p:CoverletOutputFormat=opencover \
  /p:CoverletSkipAutoProps=true \
  /p:Exclude=[*]*Migrations.*
set -e

dotnet reportgenerator \
  -reports:**/${OUTPUTDIR}/coverage.opencover.xml \
  -targetdir:${OUTPUTDIR}