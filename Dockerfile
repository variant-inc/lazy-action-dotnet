FROM gittools/gitversion:5.6.5-alpine.3.12-x64-5.0

ENV  DOTNET_SDK_VERSION=5.0.102

# Install .NET SDK
RUN wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='91ac9ea608b38402b2424d7754a823fade38261904a0fbb087f982b324aacf322c3500b520507f21b4aaac40eb059d8ef6d1656fd4f161d5afde2950210e86e8' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -oxzf dotnet.tar.gz ./packs ./sdk ./templates ./LICENSE.txt ./ThirdPartyNotices.txt \
    && rm dotnet.tar.gz \
    # Trigger first run experience by running arbitrary cmd
    && dotnet help

RUN apk add --no-cache tzdata ca-certificates

#install docker
RUN apk update && apk add --no-cache docker-cli
#install jdk
RUN apk --no-cache add openjdk11
RUN apk --no-cache add jq

#install python and awscli
RUN apk add --no-cache \
        python3 \
        py3-pip  &&  ln -sf python3 /usr/bin/python\
    && pip3 install --upgrade pip \
    && pip3 install \
        awscli \
    && rm -rf /var/cache/apk/*

RUN aws --version   # Just to make sure its installed alright
RUN ln -s /tools/dotnet-gitversion /usr/local/bin/gitversion
COPY entrypoint.sh /entrypoint.sh
COPY lazy-scripts /lazy-scripts
ENTRYPOINT ["/entrypoint.sh"]
