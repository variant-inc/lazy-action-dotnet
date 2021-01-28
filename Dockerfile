FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine

ENV PATH="$PATH:/root/.dotnet/tools"

RUN apk add --no-cache bash \
    curl

RUN curl -sL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet.sh &&\
  chmod +x /tmp/dotnet.sh &&\
  /tmp/dotnet.sh --install-dir "/usr/bin" &&\
  dotnet tool install --global GitVersion.Tool --version 5.6.4 

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

RUN curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip -q awscliv2.zip && \
  ./aws/install &&\
  rm -f awscliv2.zip
RUN aws --version   # Just to make sure its installed alright

RUN ln -s /root/.dotnet/tools/dotnet-gitversion /usr/local/bin/gitversion
COPY entrypoint.sh /entrypoint.sh
COPY lazy-scripts /lazy-scripts
ENTRYPOINT ["/entrypoint.sh"]
