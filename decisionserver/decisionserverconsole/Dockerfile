FROM maven:3.5.2-jdk-7-alpine AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps
COPY $ODMDOCKERDIR/welcomepage /welcomepage
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources
COPY $ODMDOCKERDIR/common/features $SCRIPT
COPY $ODMDOCKERDIR/decisionserver/decisionserverconsole/script $SCRIPT
COPY $ODMDOCKERDIR/decisionserver/decisionserverruntime/script $SCRIPT
# Install missing require package in the alpine builder image
RUN apk add --no-cache bash perl
# Build Welcome page
RUN cd /welcomepage; mvn -B clean install | grep -v 'Download.*'
RUN mkdir -p $APPS

# Decision Server Console
COPY ./executionserver/applicationservers/WLP855/res.war $APPS
COPY ./executionserver/applicationservers/WLP855/DecisionService.war $APPS

RUN chmod -R a+x $SCRIPT && sync && if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

RUN $SCRIPT/extractApp.sh res.war && $SCRIPT/extractApp.sh DecisionService.war

RUN $SCRIPT/changeParamValue.sh management.protocol jmx tcpip $APPS/res.war/WEB-INF/web.xml && \
		$SCRIPT/changeParamValue.sh autoCreateSchema false true $APPS/res.war/WEB-INF/web.xml

RUN $SCRIPT/loadFeatures.sh $SCRIPT


FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

ENV APP_NAME DecisionServerConsole
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps
ENV CONNECTION_POOL_SIZE 20


COPY $ODMDOCKERDIR/decisionserver/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionserverconsole/config /config
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
EXPOSE 9080 9443 1883

ENTRYPOINT ["/opt/ibm/docker/docker-server"]
CMD ["/script/run.sh"]
