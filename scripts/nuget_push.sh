#!/bin/sh -l

set -eux

: "$INPUT_NUGET_SRC_PROJECT"

cd "$GITHUB_WORKSPACE"

mkdir -p out

dotnet pack "$INPUT_NUGET_SRC_PROJECT" --no-restore -c Release --version-suffix "$IMAGE_VERSION" -o /out
dotnet nuget push "**/*.nupkg" --source github --skip-duplicate

rm -rf out
