FROM maven:3.5.2-jdk-7-alpine AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
COPY $ODMDOCKERDIR/welcomepage /welcomepage

RUN cd /welcomepage; mvn clean install

FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
LABEL ProductID="xxxxxxxxxxxxxxxxx"
LABEL ProductName="IBM Operational Decision Manager"
LABEL ProductVersion=$ODMVERSION
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

ENV APP_NAME DecisionRunner
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV CONNECTION_POOL_SIZE 60
ENV SCRIPT /script
ENV APPS /config/apps

COPY $ODMDOCKERDIR/decisionserver/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionrunner/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionrunner/script $SCRIPT
COPY $ODMDOCKERDIR/common/config /config
COPY $ODMDOCKERDIR/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY $ODMDOCKERDIR/common/security/keystore.jks /config/security/keystore.jks
COPY $ODMDOCKERDIR/common/security/truststore.jks /config/security/truststore.jks
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources

COPY ./executionserver/applicationservers/WLP855/DecisionRunner.war $APPS

RUN chmod -R a+x $SCRIPT && \
    sync && \
    if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

RUN $SCRIPT/extractApp.sh DecisionRunner.war

RUN /opt/ibm/wlp/bin/installUtility install concurrent-1.0 --acceptLicense

RUN $SCRIPT/changeParamValue.sh ForceDatabaseTableCreation false true $APPS/DecisionRunner.war/WEB-INF/web.xml

EXPOSE 9080 9443

ENTRYPOINT ["/opt/ibm/docker/docker-server"]
CMD ["/script/rundr.sh"]
