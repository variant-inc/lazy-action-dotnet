FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine3.12

#install asp.net libraries
RUN aspnetcore_version=3.1.11 \
    && wget -O aspnetcore.tar.gz https://dotnetcli.azureedge.net/dotnet/aspnetcore/Runtime/$aspnetcore_version/aspnetcore-runtime-$aspnetcore_version-linux-musl-x64.tar.gz \
    && aspnetcore_sha512='dfe6c191cbd87cf926a85da59095171df13c8bef8a5a8b7089c986475c4f3c508c66302ec008bee9ef458c2b2a5f9c348371139a2cddc3d9e0d74e879bc0f31a' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && tar -ozxf aspnetcore.tar.gz -C /usr/share/dotnet ./shared/Microsoft.AspNetCore.App \
    && rm aspnetcore.tar.gz

RUN apk add --no-cache tzdata ca-certificates

#install docker
RUN apk update && apk add --no-cache docker-cli
#install jdk
RUN apk --no-cache add openjdk11

#install python and awscli
RUN apk add --no-cache \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install \
        awscli \
    && rm -rf /var/cache/apk/*

RUN aws --version   # Just to make sure its installed alright

COPY entrypoint.sh /entrypoint.sh
COPY lazy-scripts /lazy-scripts
ENTRYPOINT ["/entrypoint.sh"]
