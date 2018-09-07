ARG FROMLIBERTY
FROM maven:3.5.2-jdk-8-alpine AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV THIRDPARTY /thirdpartylib
COPY $ODMDOCKERDIR/welcomepage /welcomepage

RUN cd /welcomepage; mvn -B clean install | grep -v 'Download.*'
COPY $ODMDOCKERDIR/common/script $SCRIPT
# Use production liberty if needed
COPY $ODMDOCKERDIR/resources/* /wlp-embeddable/
RUN chmod a+x $SCRIPT/fixWLPForProduction.sh && sync && $SCRIPT/fixWLPForProduction.sh

# Setup the variable
ENV SCRIPT /script
ENV APPS /config/apps

# Copy working files
COPY ./teamserver/lib/* /teamserver/lib/
COPY ./executionserver/lib/* /executionserver/lib/
COPY $ODMDOCKERDIR/decisioncenter/config /config
COPY $ODMDOCKERDIR/decisioncenter/script $SCRIPT
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources
COPY $ODMDOCKERDIR/common/features $SCRIPT
RUN apk add --no-cache zip bash perl ca-certificates wget

RUN mkdir work;cd work;zip -r decision-center-client-api.zip /teamserver/lib /executionserver/lib/javax.batch-api-ibm-1.0-patch5407.jar /executionserver/lib/jrules-cdi-core.jar /executionserver/lib/javax.inject-1.jar

COPY $ODMDOCKERDIR/common/script $SCRIPT
RUN chmod -R a+x $SCRIPT && \
    sync && \
	  if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

# Decision Center
RUN mkdir -p $APPS
COPY ./teamserver/applicationservers/WLP855/teamserver*.war $APPS/
COPY ./teamserver/applicationservers/WLP855/decisioncenter*.war $APPS/
COPY ./teamserver/applicationservers/WLP855/decisionmodel*.war $APPS/

RUN $SCRIPT/extractApp.sh decisioncenter.war && \
    $SCRIPT/extractApp.sh decisionmodel.war && \
    $SCRIPT/extractApp.sh teamserver.war && \
    $SCRIPT/extractApp.sh decisioncenter-api.war && \
	  mkdir -p $APPS/decisioncenter.war/WEB-INF/classes/config

RUN $SCRIPT/changeParamValue.sh com.ibm.rules.decisioncenter.setup.configuration-file . \\/config\\/decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/web.xml
RUN $SCRIPT/loadFeatures.sh $SCRIPT

FROM ${FROMLIBERTY}
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
LABEL ProductID="xxxxxxxxxxxxxxxxx"
LABEL ProductName="IBM Operational Decision Manager"
LABEL ProductVersion=$ODMVERSION
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

ENV LANG C.UTF-8
ENV APP_NAME DecisionCenter
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps

COPY $ODMDOCKERDIR/decisioncenter/config /config
COPY $ODMDOCKERDIR/decisioncenter/script $SCRIPT
COPY $ODMDOCKERDIR/common/config /config

COPY $ODMDOCKERDIR/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY $ODMDOCKERDIR/common/security/keystore.jks /config/security/keystore.jks
COPY $ODMDOCKERDIR/common/security/truststore.jks /config/security/truststore.jks

COPY $ODMDOCKERDIR/common/drivers /config/resources

# Welcome page
COPY --from=builder /welcomepage/target/welcomepage.war $APPS
# Copy Artifact
COPY --from=builder $APPS $APPS
COPY --from=builder /work/decision-center-client-api.zip $APPS/decisioncenter.war/assets/decision-center-client-api.zip
COPY --from=builder /config/resources/postgres*  /config/resources
COPY --from=builder $SCRIPT $SCRIPT
COPY --from=builder /wlp-embeddable/wlp  /opt/ibm/wlp
EXPOSE 9060 9453

ENTRYPOINT ["/opt/ibm/docker/docker-server"]
CMD ["/script/rundc.sh"]
