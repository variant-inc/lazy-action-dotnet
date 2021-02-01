#!/bin/sh -l

set -eu

: "$INPUT_NUGET_SRC_PROJECT"

cd "$GITHUB_WORKSPACE"

mkdir -p out

dotnet pack "$INPUT_NUGET_SRC_PROJECT" --no-restore -c Release --version-suffix "$IMAGE_VERSION" -o /out
if [ -n "$INPUT_NUGET_PACKAGE_NAME" ]; then
  dotnet nuget push "/out/**/*.nupkg" --source github --skip-duplicate --api-key "$GITHUB_TOKEN" -p:PackageID="$INPUT_NUGET_PACKAGE_NAME"
else
  dotnet nuget push "/out/**/*.nupkg" --source github --skip-duplicate --api-key "$GITHUB_TOKEN"
fi

rm -rf out
