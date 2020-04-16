FROM registry.cn-shanghai.aliyuncs.com/c7n/javabase:0.9.0

ENV SKYWALKING_VERSION="6.5.0"

RUN wget -qO "apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz" \
         "https://www.apache.org/dist/skywalking/${SKYWALKING_VERSION}/apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz" && \
    curl -fsSL "https://www.apache.org/dist/skywalking/${SKYWALKING_VERSION}/apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz.sha512" | sha512sum -c - && \
    tar zxf "apache-skywalking-apm-${SKYWALKING_VERSION}.tar.gz" && \
    mv apache-skywalking-apm-bin/agent / && \
    rm -rf apache-skywalking-apm* && \
    mv /agent/optional-plugins/apm-trace-ignore-plugin-${SKYWALKING_VERSION}.jar /agent/plugins