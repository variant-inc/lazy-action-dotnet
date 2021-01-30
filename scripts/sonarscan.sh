#!/bin/sh -l

set -eu

OUTPUTDIR="./coverage"
mkdir -p "$OUTPUTDIR"

SONAR_ORGANIZATION="$SONAR_ORG"

sonar_logout() {
  set +eu
  dotnet sonarscanner end /d:sonar.login="$SONAR_TOKEN"
}

sonar_args="/o:$SONAR_ORGANIZATION \
    /k:$SONAR_PROJECT_KEY \
    /d:sonar.host.url="https://sonarcloud.io" \
    /d:sonar.login=$SONAR_TOKEN \
    /d:sonar.cs.opencover.reportsPaths=**/coverage.opencover.xml \
    /d:sonar.exclusions=**/*Migrations/**/* \
    /d:sonar.scm.disabled=true \
    /d:sonar.scm.revision=$GITHUB_SHA"

if [ -z "$PULL_REQUEST_KEY" ]; then
  dotnet sonarscanner begin "$sonar_args" /d:sonar.branch.name="$BRANCH_NAME"
else
  dotnet sonarscanner begin "$sonar_args" /d:sonar.pullrequest.key="$PULL_REQUEST_KEY"
fi

trap "sonar_logout" EXIT

# unset to allow dotnet test to return with nonzero exit code
set +e
dotnet test \
  /p:CollectCoverage=true \
  /p:CoverletOutput="$OUTPUTDIR/coverage.opencover.xml" \
  /p:CoverletOutputFormat=opencover \
  /p:CoverletSkipAutoProps=true \
  /p:Exclude="[*]*Migrations.*"
set -e

dotnet reportgenerator \
  -reports:"**/$OUTPUTDIR/coverage.opencover.xml" \
  -targetdir:"$OUTPUTDIR"
