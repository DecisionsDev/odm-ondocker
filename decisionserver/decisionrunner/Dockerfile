ARG FROMLIBERTY
ARG FROMLIBERTYBUILD
ARG FROMDOCKERBUILD
FROM ${FROMDOCKERBUILD} AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps
ENV THIRDPARTY /thirdpartylib
COPY $ODMDOCKERDIR/welcomepage /welcomepage
COPY $ODMDOCKERDIR/decisionserver/decisionrunner/script $SCRIPT
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources
COPY $ODMDOCKERDIR/common/features $SCRIPT
COPY $ODMDOCKERDIR/licenses /licenses
# Install missing require package in the alpine builder image
RUN apk add --no-cache bash ca-certificates wget
# Build welcome page
RUN mkdir -p /root/.m2
COPY $ODMDOCKERDIR/settings.xml /root/.m2/
RUN cd /welcomepage; mvn -B clean install | grep -v 'Download.*' && mkdir -p $APPS
# Decision Runner
COPY ./executionserver/applicationservers/WLP*/DecisionRunner.war $APPS

RUN chmod -R a+x $SCRIPT && \
    sync && \
    if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

RUN $SCRIPT/extractApp.sh DecisionRunner.war

RUN $SCRIPT/changeParamValue.sh ForceDatabaseTableCreation false true $APPS/DecisionRunner.war/WEB-INF/web.xml
RUN $SCRIPT/manageLicense.sh && $SCRIPT/loadFeatures.sh $SCRIPT && \
chmod -R 777 $APPS

FROM ${FROMLIBERTYBUILD} AS oidc-liberty-builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
USER root
ENV SCRIPT /script
COPY  $ODMDOCKERDIR/common/script $ODMDOCKERDIR/wlp* /opt/wlppackage/
RUN mkdir $SCRIPT && mv /opt/wlppackage/*.sh $SCRIPT && $SCRIPT/installFeatures.sh
COPY --chown=1001:0 $ODMDOCKERDIR/decisionserver/config /config
COPY --chown=1001:0 $ODMDOCKERDIR/decisionserver/decisionrunner/config /config
COPY --chown=1001:0 $ODMDOCKERDIR/common/config /config
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/keystore.jks /config/security/keystore.jks
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/truststore.jks /config/security/truststore.jks

COPY --chown=1001:0 $ODMDOCKERDIR/common/drivers /config/resources
# https://www.ibm.com/support/pages/apar/IJ39517 Workaround 
RUN sed -i 's|security.provider.2=com.ibm.crypto.plus.provider.IBMJCEPlus|security.provider.2=com.ibm.crypto.provider.IBMJCE|' /opt/ibm/java/jre/lib/security/java.security && sed -i 's|security.provider.3=com.ibm.crypto.provider.IBMJCE|security.provider.3=com.ibm.crypto.plus.provider.IBMJCEPlus|' /opt/ibm/java/jre/lib/security/java.security
COPY --chown=1001:0 $ODMDOCKERDIR/common/config/jvm/jvm.options /config/configDropins/overrides/jvm.options
RUN chmod -R 777 /config
RUN sed -i 's|# Pass on to the real server run|. /script/rundr.sh|' /opt/ibm/helpers/runtime/docker-server.sh

FROM ${FROMLIBERTY}
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

LABEL name="Decision Runner"
LABEL io.k8s.display-name="Decision Runner"
LABEL description="The Decision Runner runs tests and simulations against rules."
LABEL summary="The Decision Runner runs tests and simulations against rules."
LABEL io.k8s.description="The Decision Runner runs tests and simulations against rules."

LABEL vendor="IBM"
LABEL version=${ODMVERSION}
LABEL ProductVersion=${ODMVERSION}
LABEL ProductID="IBM Operational Decision Manager for production"
LABEL io.openshift.tags="odm,dba,dbamc"


ENV APP_NAME DecisionRunner
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV CONNECTION_POOL_SIZE 60
ENV SCRIPT /script
ENV APPS /config/apps

COPY --from=oidc-liberty-builder /opt/ibm/wlp /opt/ibm/wlp
COPY --from=oidc-liberty-builder /opt/ibm/helpers/runtime/docker-server.sh /opt/ibm/helpers/runtime/docker-server.sh
# Welcome page
COPY --from=builder --chown=1001:0 /welcomepage/target/welcomepage.war $APPS
COPY --from=builder --chown=1001:0 $APPS $APPS
COPY --from=builder --chown=1001:0 /config/resources/postgres*  /config/resources
COPY --from=builder --chown=1001:0 $SCRIPT $SCRIPT
# https://www.ibm.com/support/pages/apar/IJ39517 Workaround 
COPY --from=oidc-liberty-builder  /opt/ibm/java/jre/lib/security/java.security  /opt/ibm/java/jre/lib/security/java.security
# License
COPY --from=builder  --chown=1001:0 /licenses /licenses
USER 1001
EXPOSE 9080 9443
