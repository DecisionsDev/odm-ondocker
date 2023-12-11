ARG FROMLIBERTY
ARG FROMLIBERTYBUILD
ARG FROMDOCKERBUILD
FROM ${FROMDOCKERBUILD} AS builder
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
COPY $ODMDOCKERDIR/licenses /licenses
RUN mkdir -p /root/.m2
COPY $ODMDOCKERDIR/settings.xml /root/.m2/
# Build Welcome page
RUN cd /welcomepage; mvn -B clean install  && mkdir -p $APPS
RUN apt-get update && apt-get install unzip
# Decision Server Console
COPY ./executionserver/applicationservers/WLP*/res.war $APPS

COPY ./executionserver/applicationservers/WLP*/DecisionService.war $APPS

RUN chmod -R a+x $SCRIPT && sync && if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

RUN $SCRIPT/extractApp.sh res.war && $SCRIPT/extractApp.sh DecisionService.war

RUN $SCRIPT/changeParamValue.sh management.protocol jmx tcpip $APPS/res.war/WEB-INF/web.xml && \
		$SCRIPT/changeParamValue.sh autoCreateSchema false true $APPS/res.war/WEB-INF/web.xml

RUN $SCRIPT/manageLicense.sh && $SCRIPT/loadFeatures.sh $SCRIPT && \
chmod -R 777 $APPS

FROM ${FROMLIBERTYBUILD} AS oidc-liberty-builder
ARG ODMDOCKERDIR
ARG CP4BAVERSION
ARG ODMVERSION
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV CP4BAVERSION $CP4BAVERSION
ENV ODMVERSION $ODMVERSION
USER root
ENV SCRIPT /script
COPY  $ODMDOCKERDIR/common/script $ODMDOCKERDIR/wlp* /opt/wlppackage/
RUN mkdir $SCRIPT && mv /opt/wlppackage/*.sh $SCRIPT && $SCRIPT/installFeatures.sh && chmod a+x $SCRIPT/*.sh && touch /opt/ibm/wlp/usr/servers/defaultServer/keystore.xml
COPY --chown=1001:0 $ODMDOCKERDIR/decisionserver/config /config
COPY --chown=1001:0 $ODMDOCKERDIR/decisionserver/decisionserverconsole/config /config
COPY --chown=1001:0 $ODMDOCKERDIR/common/config /config
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/keystore.jks /config/security/keystore.jks
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/truststore.jks /config/security/truststore.jks
COPY --chown=1001:0 $ODMDOCKERDIR/common/drivers /config/resources
COPY --chown=1001:0 $ODMDOCKERDIR/common/config/jvm/jvm.options /config/configDropins/overrides/jvm.options
RUN chmod -R 777 /config
RUN sed -i 's|# Pass on to the real server run|. /script/run.sh|' /opt/ibm/helpers/runtime/docker-server.sh && $SCRIPT/generateVersionFile.sh

FROM ${FROMLIBERTY}
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>
LABEL name="Decision Server Console"
LABEL description="The Decision Server console provides a web-based graphical user interface to \
 manage and monitor RuleApps, ruleset archives, JavaPrr XOMs and libraries, and decision services."
LABEL vendor="IBM"
LABEL summary="A web-based graphical user interface to manage Decision Server artifacts."
LABEL version=${ODMVERSION}
LABEL product-version=${ODMVERSION}
LABEL product-id="IBM Operational Decision Manager for production"
LABEL io.openshift.tags="odm,dba,dbamc"
LABEL io.k8s.description="A web-based graphical user interface to manage Decision Server artifacts."
LABEL io.k8s.display-name="Decision Server Console"

ENV APP_NAME DecisionServerConsole
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps
ENV CONNECTION_POOL_SIZE 20

COPY --from=oidc-liberty-builder /opt/ibm/wlp /opt/ibm/wlp
COPY --from=oidc-liberty-builder /opt/ibm/helpers/runtime/docker-server.sh /opt/ibm/helpers/runtime/docker-server.sh

# Welcome page
COPY --from=builder --chown=1001:0 /welcomepage/target/welcomepage.war $APPS
COPY --from=builder --chown=1001:0 $APPS $APPS
COPY --from=builder --chown=1001:0 /config/resources/postgres*  /config/resources
COPY --from=builder --chown=1001:0 $SCRIPT $SCRIPT
# License
COPY --from=builder  --chown=1001:0 /licenses /licenses
# Version
COPY --from=oidc-liberty-builder /opt/ibm/version.txt /opt/ibm/version.txt
USER 1001
EXPOSE 9080 9443 1883
