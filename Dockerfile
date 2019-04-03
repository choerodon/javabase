FROM adoptopenjdk/openjdk8-openj9:jdk8u202-b08_openj9-0.12.1

# Modify timezone
ENV TZ=Asia/Shanghai \
    SKYWALKING_VERSION="6.0.0-GA"

# Add mirror source
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i 's http://archive.ubuntu.com http://mirrors.aliyun.com g' /etc/apt/sources.list

# Install base packages
RUN apt-get update && apt-get install -y \
        vim \
        tar \
        zip \
        gzip \
        unzip \
        bzip2 \
        curl \
        wget \
        netcat \
        net-tools \
        locales \
        openssh-client \
        ca-certificates && \
     rm -rf /var/lib/apt/lists/* && \
     wget -qO "apache-skywalking-apm-incubating-${SKYWALKING_VERSION}.tar.gz" \
        "http://mirrors.tuna.tsinghua.edu.cn/apache/incubator/skywalking/${SKYWALKING_VERSION}/apache-skywalking-apm-incubating-${SKYWALKING_VERSION}.tar.gz" && \
     curl -fsSL https://www.apache.org/dist/incubator/skywalking/${SKYWALKING_VERSION}/apache-skywalking-apm-incubating-${SKYWALKING_VERSION}.tar.gz.sha512 | sha512sum -c - && \
     tar zxf "apache-skywalking-apm-incubating-${SKYWALKING_VERSION}.tar.gz" && \
     mv apache-skywalking-apm-incubating/agent / && \
     rm -rf apache-skywalking-apm-incubating*
