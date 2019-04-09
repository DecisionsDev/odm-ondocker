ARG FROMLIBERTY
FROM maven:3.5.2-jdk-8-alpine AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps

RUN mkdir -p $SCRIPT && \
		mkdir -p /config/resources && \
		mkdir -p /wlp-embeddable/

COPY $ODMDOCKERDIR/welcomepage /welcomepage
COPY $ODMDOCKERDIR/decisionserver/decisionserverruntime/script $SCRIPT
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources
COPY $ODMDOCKERDIR/licenses /licenses

# Use production liberty if needed
COPY $ODMDOCKERDIR/resources/* /wlp-embeddable/
RUN echo "Use the liberty image : $FROMLIBERTY" && chmod a+x $SCRIPT/fixWLPForProduction.sh && sync && $SCRIPT/fixWLPForProduction.sh
# Install missing require package in the alpine builder image
RUN apk add --no-cache bash ca-certificates wget
# Build welcome page

RUN cd /welcomepage; mvn -B clean install | grep -v 'Download.*' && mkdir -p $APPS

RUN chmod -R a+x $SCRIPT && \
    sync && \
    if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi


# Decision Server Runtime
COPY ./executionserver/applicationservers/WLP*/DecisionService.war $APPS

RUN $SCRIPT/manageLicense.sh && $SCRIPT/extractApp.sh DecisionService.war && \
chmod -R 777 $APPS

FROM ${FROMLIBERTY}
ARG ODMDOCKERDIR
ARG ODMVERSION
ARG DECISIONSERVERCONSOLE_NAME
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

LABEL name="Decision Server Runtime"
LABEL io.k8s.display-name="Decision Server Runtime"
LABEL description="The Decision Service Runtime exposes a decision service as \
 a web service with REST/JSON endpoints."


LABEL summary="The Decision Server Runtime REST API."
LABEL io.k8s.description="The Decision Server Runtime REST API."

LABEL vendor="IBM"
LABEL version=${ODMVERSION}
LABEL io.openshift.tags="odm,dba,dbamc"



ENV APP_NAME DecisionServerRuntime
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps
ENV CONNECTION_POOL_SIZE 60
ENV DECISIONSERVERCONSOLE_NAME $DECISIONSERVERCONSOLE_NAME

COPY --chown=1001:0 $ODMDOCKERDIR/decisionserver/config /config
COPY --chown=1001:0 $ODMDOCKERDIR/decisionserver/decisionserverruntime/config /config
COPY --chown=1001:0 $ODMDOCKERDIR/common/config /config
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/keystore.jks /config/security/keystore.jks
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/truststore.jks /config/security/truststore.jks
COPY --chown=1001:0 $ODMDOCKERDIR/common/drivers /config/resources
# Welcome page
COPY --from=builder --chown=1001:0 /welcomepage/target/welcomepage.war $APPS
COPY --from=builder --chown=1001:0 $APPS $APPS
COPY --from=builder --chown=1001:0 /config/resources/postgres*  /config/resources
COPY --from=builder --chown=1001:0 $SCRIPT $SCRIPT
COPY --from=builder --chown=1001:0 /wlp-embeddable/wlp  /opt/ibm/wlp
# License
COPY --from=builder  --chown=1001:0 /licenses /licenses
EXPOSE 9080 9443

CMD ["/script/runds.sh"]
