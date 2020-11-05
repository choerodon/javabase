# ref: https://github.com/AdoptOpenJDK/openjdk-docker/blob/9b88ff88450a006bb669e4def8dab866e56baad9/8/jdk/ubuntu/Dockerfile.openj9.releases.full
FROM ubuntu:20.04

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update \
    && apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION jdk8u272-b10_openj9-0.23.0

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       ppc64el|ppc64le) \
         ESUM='71f649a103e2abab58c062adc7cca0a60dca5feba1cb868cdf87bba1e1a9d333'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u272-b10_openj9-0.23.0/OpenJDK8U-jdk_ppc64le_linux_openj9_8u272b10_openj9-0.23.0.tar.gz'; \
         ;; \
       s390x) \
         ESUM='893caadb7d61cfc895f40d35911ce4b3b400443de05f38c1936a91107271a68d'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u272-b10_openj9-0.23.0/OpenJDK8U-jdk_s390x_linux_openj9_8u272b10_openj9-0.23.0.tar.gz'; \
         ;; \
       arm64) \
         ESUM='bbc78dc8caf25372578a95287bcf672c4bf62af23939d4a988634b2a1356cd89'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u272-b10_openj9-0.23.0/OpenJDK8U-jdk_aarch64_linux_openj9_8u272b10_openj9-0.23.0.tar.gz'; \
         ;; \
       amd64|x86_64) \
         ESUM='ca852f976e5b27ccd9b73a527a517496bda865b2ae2a85517ca74486fb8de7da'; \
         BINARY_URL='https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u272-b10_openj9-0.23.0/OpenJDK8U-jdk_x64_linux_openj9_8u272b10_openj9-0.23.0.tar.gz'; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"
ENV JAVA_TOOL_OPTIONS="-XX:+IgnoreUnrecognizedVMOptions -XX:+IdleTuningGcOnIdle"

# Create OpenJ9 SharedClassCache (SCC) for bootclasses to improve the java startup.
# Downloads and runs tomcat to generate SCC for bootclasses at /opt/java/.scc/openj9_system_scc
# Does a dry-run and calculates the optimal cache size and recreates the cache with the appropriate size.
# With SCC, OpenJ9 startup is improved ~50% with an increase in image size of ~14MB
# Application classes can be create a separate cache layer with this as the base for further startup improvement

RUN set -eux; \
    unset OPENJ9_JAVA_OPTIONS; \
    SCC_SIZE="50m"; \
    SCC_GEN_RUNS_COUNT=3; \
    DOWNLOAD_PATH_TOMCAT=/tmp/tomcat; \
    INSTALL_PATH_TOMCAT=/opt/tomcat-home; \
    TOMCAT_CHECKSUM="0db27185d9fc3174f2c670f814df3dda8a008b89d1a38a5d96cbbe119767ebfb1cf0bce956b27954aee9be19c4a7b91f2579d967932207976322033a86075f98"; \
    TOMCAT_DWNLD_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.35/bin/apache-tomcat-9.0.35.tar.gz"; \
    \
    mkdir -p "${DOWNLOAD_PATH_TOMCAT}" "${INSTALL_PATH_TOMCAT}"; \
    curl -LfsSo "${DOWNLOAD_PATH_TOMCAT}"/tomcat.tar.gz "${TOMCAT_DWNLD_URL}"; \
    echo "${TOMCAT_CHECKSUM} *${DOWNLOAD_PATH_TOMCAT}/tomcat.tar.gz" | sha512sum -c -; \
    tar -xf "${DOWNLOAD_PATH_TOMCAT}"/tomcat.tar.gz -C "${INSTALL_PATH_TOMCAT}" --strip-components=1; \
    rm -rf "${DOWNLOAD_PATH_TOMCAT}"; \
    \
    java -Xshareclasses:name=dry_run_scc,cacheDir=/opt/java/.scc,bootClassesOnly,nonFatal,createLayer -Xscmx$SCC_SIZE -version; \
    export OPENJ9_JAVA_OPTIONS="-Xshareclasses:name=dry_run_scc,cacheDir=/opt/java/.scc,bootClassesOnly,nonFatal"; \
    for i in $(seq 0 $SCC_GEN_RUNS_COUNT); \
    do \
        "${INSTALL_PATH_TOMCAT}"/bin/startup.sh; \
        sleep 5; \
        "${INSTALL_PATH_TOMCAT}"/bin/shutdown.sh; \
        sleep 5; \
    done; \
    \
    FULL=$( (java -Xshareclasses:name=dry_run_scc,cacheDir=/opt/java/.scc,printallStats 2>&1 || true) | awk '/^Cache is [0-9.]*% .*full/ {print substr($3, 1, length($3)-1)}'); \
    DST_CACHE=$(java -Xshareclasses:name=dry_run_scc,cacheDir=/opt/java/.scc,destroy 2>&1 || true); \
    SCC_SIZE=$(echo $SCC_SIZE | sed 's/.$//'); \
    SCC_SIZE=$(awk "BEGIN {print int($SCC_SIZE * $FULL / 100.0)}"); \
    [ "${SCC_SIZE}" -eq 0 ] && SCC_SIZE=1; \
    SCC_SIZE="${SCC_SIZE}m"; \
    java -Xshareclasses:name=openj9_system_scc,cacheDir=/opt/java/.scc,bootClassesOnly,nonFatal,createLayer -Xscmx$SCC_SIZE -version; \
    unset OPENJ9_JAVA_OPTIONS; \
    \
    export OPENJ9_JAVA_OPTIONS="-Xshareclasses:name=openj9_system_scc,cacheDir=/opt/java/.scc,bootClassesOnly,nonFatal"; \
    for i in $(seq 0 $SCC_GEN_RUNS_COUNT); \
    do \
        "${INSTALL_PATH_TOMCAT}"/bin/startup.sh; \
        sleep 5; \
        "${INSTALL_PATH_TOMCAT}"/bin/shutdown.sh; \
        sleep 5; \
    done; \
    \
    FULL=$( (java -Xshareclasses:name=openj9_system_scc,cacheDir=/opt/java/.scc,printallStats 2>&1 || true) | awk '/^Cache is [0-9.]*% .*full/ {print substr($3, 1, length($3)-1)}'); \
    echo "SCC layer is $FULL% full."; \
    rm -rf "${INSTALL_PATH_TOMCAT}"; \
    if [ -d "/opt/java/.scc" ]; then \
          chmod -R 0777 /opt/java/.scc; \
    fi; \
    \
    echo "SCC generation phase completed";

ENV OPENJ9_JAVA_OPTIONS="-Xshareclasses:name=openj9_system_scc,cacheDir=/opt/java/.scc,readonly,nonFatal"

ENV LANG=C.UTF-8 \
    TZ="Asia/Shanghai" \
    TINI_VERSION="v0.19.0"

# Install base packages
RUN apt-get update; \
    apt-get install -y \
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
         ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -qO "tini-static-${dpkgArch}" \
       "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-${dpkgArch}"; \
    wget -qO "tini-static-${dpkgArch}.sha256sum" \
       "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-${dpkgArch}.sha256sum"; \
    sha256sum --strict --check <"tini-static-${dpkgArch}.sha256sum"; \
    rm -r "tini-static-${dpkgArch}.sha256sum"; \
    mv "tini-static-${dpkgArch}" /usr/bin/tini; \
    chmod +x /usr/bin/tini; \
    tini --version

# Add mirror source
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak; \
    sed -i 's http://.*.ubuntu.com http://mirrors.aliyun.com g' /etc/apt/sources.list

ENTRYPOINT ["tini", "--"]