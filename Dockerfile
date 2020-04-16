FROM adoptopenjdk/openjdk8-openj9:x86_64-debian-jdk8u242-b08_openj9-0.18.1-slim

ENV LANG=C.UTF-8 \
    TZ="Asia/Shanghai" \
    TINI_VERSION="v0.18.0"

# Add mirror source
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i 's http://.*.debian.org http://mirrors.aliyun.com g' /etc/apt/sources.list

# Fix base image
RUN apt-get update && apt-get install -y \
         libidn2-0 && \
      rm -rf /var/lib/apt/lists/*

# Install base packages
RUN apt-get update && apt-get install -y \
         vim \
         tar \
         zip \
         curl \
         wget \
         gzip \
         unzip \
         bzip2 \
         gnupg \
         netcat \
         dirmngr \
         locales \
         net-tools \
         fontconfig \
         openssh-client \
         ca-certificates && \
      rm -rf /var/lib/apt/lists/* && \
      wget -qO /usr/local/bin/tini \
         "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-amd64" && \
      wget -qO /usr/local/bin/tini.asc \
         "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-amd64.asc" && \
      gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 \
          --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 && \
      gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini && \
      rm -r /usr/local/bin/tini.asc && \
      chmod +x /usr/local/bin/tini && \
      tini --version

ENTRYPOINT ["tini", "--"]