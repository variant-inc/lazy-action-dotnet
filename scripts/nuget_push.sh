#!/bin/sh -l

set -eu

cd "$GITHUB_WORKSPACE"

mkdir -p out

dotnet pack --no-restore -c Release --version-suffix "$IMAGE_VERSION" -o /out
dotnet nuget push "/out/**/*.nupkg" --source github --skip-duplicate --api-key "$INPUT_NUGET_PUSH_TOKEN"

rm -rf out
