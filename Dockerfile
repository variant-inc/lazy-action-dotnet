FROM gittools/gitversion:5.6.5-alpine.3.12-x64-5.0

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
