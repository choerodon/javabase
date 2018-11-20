FROM openjdk:8u181-jdk-slim-stretch
# Modify timezone
ENV TZ=Asia/Shanghai \
    SKYWALKING_VERSION="6.0.0-alpha"

# Add mirror source
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo 'deb http://mirrors.aliyun.com/debian stretch main contrib non-free' >> /etc/apt/sources.list && \
    echo 'deb http://mirrors.aliyun.com/debian stretch-proposed-updates main contrib non-free' >> /etc/apt/sources.list && \
    echo 'deb http://mirrors.aliyun.com/debian stretch-updates main contrib non-free' >> /etc/apt/sources.list && \
    echo 'deb http://mirrors.aliyun.com/debian-security/ stretch/updates main non-free contrib' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.aliyun.com/debian stretch main contrib non-free' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.aliyun.com/debian stretch-proposed-updates main contrib non-free' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.aliyun.com/debian stretch-updates main contrib non-free' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.aliyun.com/debian-security/ stretch/updates main non-free contrib' >> /etc/apt/sources.list
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
     wget -O "apache-skywalking-apm-incubating-${SKYWALKING_VERSION}.tar.gz" \
        "http://mirrors.tuna.tsinghua.edu.cn/apache/incubator/skywalking/${SKYWALKING_VERSION}/apache-skywalking-apm-incubating-${SKYWALKING_VERSION}.tar.gz" && \
     curl -fsSL https://www.apache.org/dist/incubator/skywalking/${SKYWALKING_VERSION}/apache-skywalking-apm-incubating-${SKYWALKING_VERSION}.tar.gz.sha512 | sha512sum -c - && \
     tar zxf "apache-skywalking-apm-incubating-${SKYWALKING_VERSION}.tar.gz" && \
     mv apache-skywalking-apm-incubating/agent / && \
     rm -rf apache-skywalking-apm-incubating*