ARG VERSION=3.1-alpine

FROM mcr.microsoft.com/dotnet/core/aspnet:$VERSION
RUN apk add --no-cache tzdata
WORKDIR /app
COPY publish .
