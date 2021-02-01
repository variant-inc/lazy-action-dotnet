#!/bin/sh -l

set -eu

: "$INPUT_NUGET_SRC_PROJECT"

cd "$GITHUB_WORKSPACE"

mkdir -p out


if [ -n "$INPUT_NUGET_PACKAGE_NAME" ]; then
  dotnet pack "$INPUT_NUGET_SRC_PROJECT" --no-restore -c Release --version-suffix "$IMAGE_VERSION" -o /out -p:PackageID="$INPUT_NUGET_PACKAGE_NAME"
else
  dotnet pack "$INPUT_NUGET_SRC_PROJECT" --no-restore -c Release --version-suffix "$IMAGE_VERSION" -o /out
fi
dotnet nuget push "/out/**/*.nupkg" --source github --skip-duplicate --api-key "$GITHUB_TOKEN"

rm -rf out
