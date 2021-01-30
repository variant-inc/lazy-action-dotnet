FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine

ARG BUILD_DATE
ARG BUILD_REVISION
ARG BUILD_VERSION

LABEL com.github.actions.name="Lazy Action Dotnet" \
  com.github.actions.description="Build and Push Dotnet Packages" \
  com.github.actions.icon="code" \
  com.github.actions.color="red" \
  maintainer="Variant DevOps <devops@drivevariant.com>" \
  org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.revision=$BUILD_REVISION \
  org.opencontainers.image.version=$BUILD_VERSION \
  org.opencontainers.image.authors="Variant DevOps <devops@drivevariant.com>" \
  org.opencontainers.image.url="https://github.com/variant-inc/lazy-action-dotnet" \
  org.opencontainers.image.source="https://github.com/variant-inc/lazy-action-dotnet" \
  org.opencontainers.image.documentation="https://github.com/variant-inc/lazy-action-dotnet" \
  org.opencontainers.image.vendor="AWS ECR" \
  org.opencontainers.image.description="Build and Push Dotnet Packages"

ARG GLIBC_VER=2.31-r0
ENV PATH="$PATH:/root/.dotnet/tools"

RUN apk add --no-cache \
  bash \
  curl \
  tzdata ca-certificates \
  docker-cli \
  openjdk11 \
  jq \
  python3 \
  binutils \
  py3-pip &&\
  ln -sf python3 /usr/bin/python \
  rm -rf /var/lib/apt/lists/* &&\
  \
  curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub &&\
  curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk &&\
  curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk &&\
  apk add --no-cache glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk &&\
  \
  curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip &&\
  unzip awscliv2.zip &&\
  aws/install &&\
  rm -rf \
  awscliv2.zip \
  aws \
  /usr/local/aws-cli/v2/*/dist/aws_completer \
  /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
  /usr/local/aws-cli/v2/*/dist/awscli/examples \
  apk --no-cache del binutils &&\
  rm glibc-${GLIBC_VER}.apk &&\
  rm glibc-bin-${GLIBC_VER}.apk &&\
  rm -rf /var/cache/apk/*

COPY . /
RUN chmod +x /entrypoint.sh &&\
  chmod +x -R /scripts

ENTRYPOINT ["/entrypoint.sh"]
