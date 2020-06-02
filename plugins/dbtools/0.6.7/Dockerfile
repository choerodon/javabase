FROM registry.cn-shanghai.aliyuncs.com/c7n/javabase:0.9.0

ENV TOOL_LIQUIBASE_VERSION="0.17.0.RELEASE" \

ADD --chown=www-data:www-data https://nexus.choerodon.com.cn/repository/choerodon-maven/io/choerodon/choerodon-tool-liquibase/${TOOL_LIQUIBASE_VERSION}/choerodon-tool-liquibase-${TOOL_LIQUIBASE_VERSION}.jar \
    /var/choerodon/choerodon-tool-liquibase.jar

USER www-data