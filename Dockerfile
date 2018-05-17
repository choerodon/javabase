FROM alpine:3.5
# Install base packages
RUN apk update && apk add curl bash tree tzdata \
    && cp -r -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo -ne "Alpine Linux 3.4 image. (`uname -rsv`)\n" >> /root/.built
# Define bash as default command
RUN apk --no-cache add openjdk8-jre ttf-droid
