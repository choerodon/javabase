FROM openjdk:8u181-jre-slim-stretch
# Modify timezone
ENV TZ=Asia/Shanghai
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
        vim locales openssh-client ca-certificates tar gzip net-tools netcat unzip zip bzip2 curl wget \
	&& rm -rf /var/lib/apt/lists/*