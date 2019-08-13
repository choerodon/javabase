FROM adoptopenjdk/openjdk8-openj9:jdk8u202-b08_openj9-0.12.1

# Modify timezone
ENV LANG=C.UTF-8 \
    TZ="Asia/Shanghai" \
    TINI_VERSION="v0.18.0" \
    SKYWALKING_VERSION="6.3.0"

# Add mirror source
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i 's archive.ubuntu.com mirrors.aliyun.com g' /etc/apt/sources.list

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
      export GNUPGHOME="$(mktemp -d)" && \
      for key in 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7; do \
         gpg --batch --keyserver hkps://mattrobenolt-keyserver.global.ssl.fastly.net:443 --recv-keys "$key" ; \
      done && \
      gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini && \
      gpgconf --kill all && \
      rm -r "$GNUPGHOME" /usr/local/bin/tini.asc && \
      chmod +x /usr/local/bin/tini && \
      tini --version && \
      wget -qO "apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz" \
         "https://www.apache.org/dist/skywalking/${SKYWALKING_VERSION}/apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz" && \
      curl -fsSL "https://www.apache.org/dist/skywalking/${SKYWALKING_VERSION}/apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz.sha512" | sha512sum -c - && \
      tar zxf "apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz" && \
      mv apache-skywalking-apm-bin/agent / && \
      rm -rf apache-skywalking-apm* && \
      mv /agent/optional-plugins/apm-trace-ignore-plugin-${SKYWALKING_VERSION}.jar /agent/plugins

ENTRYPOINT ["tini", "--"]