ARG VERSION=3.1-alpine

FROM mcr.microsoft.com/dotnet/core/sdk:$VERSION AS build-env
ARG GITHUB_USER
ARG GITHUB_TOKEN
WORKDIR /app
RUN apk add --no-cache tzdata

# Copy csproj and restore as distinct layers
COPY *.sln .
COPY *.csproj ./
RUN dotnet restore

FROM build-env AS test-env
RUN apk add --no-cache tzdata
RUN ["dotnet", "test", "--no-build", "--no-restore"]

# Copy everything else and publish
FROM build-env AS publish-project
COPY . ./
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/core/aspnet:$VERSION
RUN apk add --no-cache tzdata
WORKDIR /app
COPY --from=publish-project /app/publish .