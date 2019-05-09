ARG FROMLIBERTY
FROM maven:3.5.2-jdk-8-alpine AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV THIRDPARTY /thirdpartylib
# Setup the variable
ENV SCRIPT /script
ENV APPS /config/apps
COPY $ODMDOCKERDIR/welcomepage /welcomepage

RUN cd /welcomepage; mvn -B clean install | grep -v 'Download.*'
COPY $ODMDOCKERDIR/common/script $SCRIPT
# Use production liberty if needed
COPY $ODMDOCKERDIR/resources/* /wlp-embeddable/
RUN chmod a+x $SCRIPT/fixWLPForProduction.sh && sync && $SCRIPT/fixWLPForProduction.sh



# Copy working files
COPY ./teamserver/lib/* /teamserver/lib/
COPY ./executionserver/lib/* /executionserver/lib/
COPY $ODMDOCKERDIR/decisioncenter/config /config
COPY $ODMDOCKERDIR/decisioncenter/script $SCRIPT
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources
COPY $ODMDOCKERDIR/common/features $SCRIPT
COPY $ODMDOCKERDIR/licenses /licenses
RUN apk add --no-cache zip bash ca-certificates wget

RUN mkdir work;cd work && \
	if [ -f /executionserver/lib/jrules-cdi-api.jar ]; then zip -r decision-center-client-api.zip /teamserver/lib /executionserver/lib/javax.batch-api-ibm-1.0-patch5407.jar /executionserver/lib/jrules-cdi-api.jar /executionserver/lib/javax.inject-1.jar; else zip -r decision-center-client-api.zip /teamserver/lib /executionserver/lib/javax.batch-api-ibm-1.0-patch5407.jar /executionserver/lib/jrules-cdi-core.jar /executionserver/lib/javax.inject-1.jar; fi

COPY $ODMDOCKERDIR/common/script $SCRIPT
RUN chmod -R a+x $SCRIPT && \
    sync && \
	  if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

# Decision Center
RUN mkdir -p $APPS
COPY ./teamserver/applicationservers/WLP*/teamserver*.war $APPS/
COPY ./teamserver/applicationservers/WLP*/decision*.war $APPS/

RUN $SCRIPT/extractApp.sh decisioncenter.war && \
    $SCRIPT/extractApp.sh decisionmodel.war && \
    $SCRIPT/extractApp.sh teamserver.war && \
    $SCRIPT/extractApp.sh decisioncenter-api.war && \
	  mkdir -p $APPS/decisioncenter.war/WEB-INF/classes/config
RUN $SCRIPT/changeParamValue.sh com.ibm.rules.decisioncenter.setup.configuration-file \.\\/config\\/decisioncenter-configuration.properties \\/config\\/decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/web.xml
RUN $SCRIPT/manageLicense.sh && $SCRIPT/loadFeatures.sh $SCRIPT && \
chmod -R 777 $APPS


FROM ${FROMLIBERTY}
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

LABEL name="Decision Center"
LABEL io.k8s.display-name="Decision Center"
LABEL description="Decision Center is a web application where business users author, model, and manage decisions\
 with limited or no dependence on the IT department."


LABEL summary="Decision Center is a web application to manage and author decisions."
LABEL io.k8s.description="Decision Center is a web application to manage and author decisions."

LABEL vendor="IBM"
LABEL version=${ODMVERSION}
LABEL io.openshift.tags="odm,dba,dbamc"

ENV APP_NAME DecisionCenter
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps

COPY --chown=1001:0 $ODMDOCKERDIR/decisioncenter/config /config
COPY --chown=1001:0 $ODMDOCKERDIR/decisioncenter/script $SCRIPT
COPY --chown=1001:0 $ODMDOCKERDIR/common/config /config

COPY --chown=1001:0 $ODMDOCKERDIR/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/keystore.jks /config/security/keystore.jks
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/truststore.jks /config/security/truststore.jks

COPY --chown=1001:0 $ODMDOCKERDIR/common/drivers /config/resources

# Welcome page
COPY --from=builder --chown=1001:0 /welcomepage/target/welcomepage.war $APPS


# Copy Artifact
COPY --from=builder --chown=1001:0 $APPS $APPS
COPY --from=builder --chown=1001:0 /work/decision-center-client-api.zip $APPS/decisioncenter.war/assets/decision-center-client-api.zip
COPY --from=builder --chown=1001:0 /config/resources/postgres*  /config/resources
COPY --from=builder --chown=1001:0 $SCRIPT $SCRIPT
COPY --from=builder --chown=1001:0 /wlp-embeddable/wlp  /opt/ibm/wlp
# License
COPY --from=builder  --chown=1001:0 /licenses /licenses
EXPOSE 9060 9453

CMD ["/script/rundc.sh"]
