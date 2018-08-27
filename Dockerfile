FROM alpine:3.7
# Install base packages
RUN apk add --no-cache \
    curl \
    bash \
    tree \
    tzdata \
    openjdk8-jre \
    ttf-droid
# Modify timezone
RUN cp -rf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
