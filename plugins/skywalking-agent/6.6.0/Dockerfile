FROM busybox:1.32

ENV SKYWALKING_VERSION="6.6.0"

RUN wget -qO "apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz" \
         "https://www.apache.org/dist/skywalking/${SKYWALKING_VERSION}/apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz" && \
    curl -fsSL "https://www.apache.org/dist/skywalking/${SKYWALKING_VERSION}/apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz.sha512" | sha512sum -c - && \
    tar zxf "apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz" && \
    mkdir /skywalking && \
    mv apache-skywalking-apm-bin/agent /skywalking && \
    rm -rf apache-skywalking-apm* && \
    mv /skywalking/agent/optional-plugins/apm-trace-ignore-plugin-${SKYWALKING_VERSION}.jar /skywalking/agent/plugins && \
    chown -R www-data:www-data /skywalking
USER 33