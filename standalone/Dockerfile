FROM maven:3.5.2-jdk-8-alpine AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps
ENV THIRDPARTY /thirdpartylib
RUN apk add --no-cache  perl ca-certificates wget

COPY ${ODMDOCKERDIR}/decisioncenter/script $SCRIPT
COPY ${ODMDOCKERDIR}/standalone/script $SCRIPT
COPY ${ODMDOCKERDIR}/common/script $SCRIPT
COPY ${ODMDOCKERDIR}/common/features $SCRIPT

COPY $ODMDOCKERDIR/welcomepage /welcomepage

RUN cd /welcomepage; mvn clean install  | grep -v 'Download.*'
RUN mkdir -p /config/dbdata /config/resources
COPY ${ODMDOCKERDIR}/decisioncenter/config/application.xml /config/decisionrunner_application.xml

# Begin - Configuration for the database
# Install the driver for H2 and for PostgreSQL
RUN wget -nv http://central.maven.org/maven2/com/h2database/h2/1.4.196/h2-1.4.196.jar && mv h2* /config/resources && \
    wget -nv https://jdbc.postgresql.org/download/postgresql-42.2.1.jar && mv postgres* /config/resources
# End - Configuration for the database

RUN chmod -R a+x $SCRIPT && mkdir $APPS

# Decision Center
COPY ./teamserver/applicationservers/WLP855/teamserver.war $APPS
COPY ./teamserver/applicationservers/WLP855/decisioncenter*.war $APPS/

RUN $SCRIPT/extractApp.sh decisioncenter.war && \
    $SCRIPT/extractApp.sh teamserver.war && \
    mkdir -p $APPS/decisioncenter.war/WEB-INF/classes/config

RUN $SCRIPT/changeParamValue.sh com.ibm.rules.decisioncenter.setup.configuration-file . \\/config\\/decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/web.xml

COPY ${ODMDOCKERDIR}/standalone/config/group-security-configurations.xml $APPS/decisioncenter.war/WEB-INF/classes/config/group-security-configurations.xml

# Decision Server Console
COPY ./executionserver/applicationservers/WLP855/res.war $APPS
RUN $SCRIPT/extractApp.sh res.war
RUN $SCRIPT/changeParamValue.sh autoCreateSchema false true $APPS/res.war/WEB-INF/web.xml

# Decision Server Runtime
COPY ./executionserver/applicationservers/WLP855/DecisionService.war $APPS
RUN $SCRIPT/extractApp.sh DecisionService.war

# Decision Runner
COPY ./executionserver/applicationservers/WLP855/DecisionRunner.war $APPS
RUN $SCRIPT/extractApp.sh DecisionRunner.war
RUN $SCRIPT/changeParamValue.sh ForceDatabaseTableCreation false true $APPS/DecisionRunner.war/WEB-INF/web.xml

# Load Feature
# Fix for WLP 18.0.0.2
RUN mkdir $THIRDPARTY
COPY ./executionserver/lib/jaxws $THIRDPARTY
# End Fix
RUN $SCRIPT/loadFeatures.sh $SCRIPT

FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
LABEL ProductID="xxxxxxxxxxxxxxxxx"
LABEL ProductName="IBM Operational Decision Manager for Developers"
LABEL ProductVersion=$ODMVERSION
MAINTAINER "Laurent GRATEAU <laurent.grateau@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"

ENV LANG C.UTF-8
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV APP_NAME StandaloneOdm
ENV SCRIPT /script
ENV APPS /config/apps

COPY $ODMDOCKERDIR/standalone/licenses $APPS/licenses
COPY ${ODMDOCKERDIR}/decisioncenter/config/application.xml /config/decisioncenter_application.xml
COPY ${ODMDOCKERDIR}/decisioncenter/config/application-withRestApi.xml /config
COPY ${ODMDOCKERDIR}/decisionserver/decisionrunner/config/application.xml /config/decisionrunner_application.xml
COPY ${ODMDOCKERDIR}/decisionserver/decisionserverconsole/config/application.xml /config/decisionserverconsole_application.xml
COPY ${ODMDOCKERDIR}/decisionserver/decisionserverruntime/config/application.xml /config/decisionserverruntime_application.xml
COPY ${ODMDOCKERDIR}/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY ${ODMDOCKERDIR}/common/security/keystore.jks /config/security/keystore.jks
COPY ${ODMDOCKERDIR}/common/security/truststore.jks /config/security/truststore.jks
COPY ${ODMDOCKERDIR}/standalone/config /config
COPY --from=builder /config/dbdata /config

ENV CONNECTION_POOL_SIZE 20

# Sample DB
ADD ${ODMDOCKERDIR}/standalone/data.tar.gz /upload/

# Welcome page
COPY --from=builder /welcomepage/target/welcomepage.war $APPS
COPY --from=builder /config/resources/postgres*  /config/resources
COPY --from=builder /config/resources/h2*  /config/resources
COPY --from=builder /config/dbdata /config
COPY --from=builder $APPS $APPS
COPY --from=builder $SCRIPT $SCRIPT
VOLUME ["/config/dbdata/"]
EXPOSE 9060 9453

ENTRYPOINT ["/opt/ibm/docker/docker-server"]
CMD ["/script/runserver.sh"]
