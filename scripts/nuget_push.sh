#!/bin/sh -l

set -eu

: "$INPUT_NUGET_PROJECT_PATH"

cd "$GITHUB_WORKSPACE"

mkdir -p out


if [ -n "$INPUT_NUGET_PACKAGE_NAME" ]; then
  echo "Taking nuget pacakge name"
  dotnet pack "$INPUT_NUGET_PROJECT_PATH" --no-restore -c Release --version-suffix "$IMAGE_VERSION" -o /out -p:PackageID="$INPUT_NUGET_PACKAGE_NAME"
else
  dotnet pack "$INPUT_NUGET_PROJECT_PATH" --no-restore -c Release --version-suffix "$IMAGE_VERSION" -o /out
fi
dotnet nuget push "/out/**/*.nupkg" --source github --skip-duplicate --api-key "$GITHUB_TOKEN"

rm -rf out
