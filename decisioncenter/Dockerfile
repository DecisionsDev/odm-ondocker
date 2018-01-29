FROM alpine:3.5 AS builder
COPY ./teamserver/lib/* /teamserver/lib/
COPY ./executionserver/lib/* /executionserver/lib/

RUN apk add --no-cache zip
RUN mkdir work;cd work;zip -r decision-center-client-api.zip /teamserver/lib /executionserver/lib/javax.batch-api-ibm-1.0-patch5407.jar /executionserver/lib/jrules-cdi-core.jar /executionserver/lib/javax.inject-1.jar

FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
LABEL ProductID="xxxxxxxxxxxxxxxxx"
LABEL ProductName="IBM Operational Decision Manager"
LABEL ProductVersion=$ODMVERSION
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

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
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources

COPY ./teamserver/applicationservers/WLP855/teamserver.war $APPS
COPY ./teamserver/applicationservers/WLP855/decisioncenter*.war $APPS/

RUN chmod -R a+x $SCRIPT && \
    sync && \
	  if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

RUN $SCRIPT/extractApp.sh decisioncenter.war && \
    $SCRIPT/extractApp.sh teamserver.war && \
	  mkdir -p $APPS/decisioncenter.war/WEB-INF/classes/config

RUN $SCRIPT/changeParamValue.sh com.ibm.rules.decisioncenter.setup.configuration-file . \\/config\\/decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/web.xml

COPY $ODMDOCKERDIR/decisioncenter/decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
COPY --from=builder /work/decision-center-client-api.zip $APPS/decisioncenter.war/assets/decision-center-client-api.zip


EXPOSE 9060 9453

CMD ["/script/rundc.sh"]
