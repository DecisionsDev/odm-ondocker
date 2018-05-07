FROM maven:3.5.2-jdk-7-alpine AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps

RUN mkdir -p $SCRIPT && \
		mkdir -p /config/resources

COPY $ODMDOCKERDIR/welcomepage /welcomepage
COPY $ODMDOCKERDIR/decisionserver/decisionserverruntime/script $SCRIPT
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources

# Install missing require package in the alpine builder image
RUN apk add --no-cache bash perl
# Build welcome page
RUN cd /welcomepage; mvn -B clean install | grep -v 'Download.*' && mkdir -p $APPS

RUN chmod -R a+x $SCRIPT && \
    sync && \
    if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

# Decision Server Runtime
COPY ./executionserver/applicationservers/WLP855/DecisionService.war $APPS

RUN $SCRIPT/extractApp.sh DecisionService.war

FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
ARG ODMVERSION
ARG DECISIONSERVERCONSOLE_NAME
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
LABEL ProductID="xxxxxxxxxxxxxxxxx"
LABEL ProductName="IBM Operational Decision Manager"
LABEL ProductVersion=$ODMVERSION
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

ENV APP_NAME DecisionServerRuntime
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps
ENV CONNECTION_POOL_SIZE 60
ENV DECISIONSERVERCONSOLE_NAME $DECISIONSERVERCONSOLE_NAME

COPY $ODMDOCKERDIR/decisionserver/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionserverruntime/config /config
COPY $ODMDOCKERDIR/common/config /config
COPY $ODMDOCKERDIR/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY $ODMDOCKERDIR/common/security/keystore.jks /config/security/keystore.jks
COPY $ODMDOCKERDIR/common/security/truststore.jks /config/security/truststore.jks
COPY $ODMDOCKERDIR/common/drivers /config/resources

# Welcome page
COPY --from=builder /welcomepage/target/welcomepage.war $APPS
COPY --from=builder $APPS $APPS
COPY --from=builder /config/resources/postgres*  /config/resources
COPY --from=builder $SCRIPT $SCRIPT
EXPOSE 9080 9443

ENTRYPOINT ["/opt/ibm/docker/docker-server"]
CMD ["/script/runds.sh"]
