ARG VERSION=5.0-alpine

FROM mcr.microsoft.com/dotnet/aspnet:$VERSION
RUN apk add --no-cache tzdata
WORKDIR /app
COPY publish .
