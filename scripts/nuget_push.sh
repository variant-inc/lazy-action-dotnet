#!/bin/sh -l

set -eux

: "$INPUT_NUGET_SRC_FOLDER"

cd "$GITHUB_WORKSPACE"

mkdir -p out

dotnet pack "$INPUT_NUGET_SRC_FOLDER" --no-restore -c Release --version-suffix "$VERSION_SUFFIX" -o /out
dotnet nuget push "**/*.nupkg" --source github --skip-duplicate

rm -rf out
