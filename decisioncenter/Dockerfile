ARG FROMLIBERTY
ARG FROMLIBERTYBUILD
ARG FROMDOCKERBUILD
FROM ${FROMDOCKERBUILD} AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV THIRDPARTY /thirdpartylib
# Setup the variable
ENV SCRIPT /script
ENV APPS /config/apps
COPY $ODMDOCKERDIR/welcomepage /welcomepage

RUN mkdir -p /root/.m2
COPY $ODMDOCKERDIR/settings.xml /root/.m2/
RUN cd /welcomepage; mvn -B clean install | grep -v 'Download.*'
COPY $ODMDOCKERDIR/common/script $SCRIPT

# Copy working files
COPY $ODMDOCKERDIR/decisioncenter/config /config
COPY $ODMDOCKERDIR/decisioncenter/script $SCRIPT
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources
COPY $ODMDOCKERDIR/common/features $SCRIPT
COPY $ODMDOCKERDIR/licenses /licenses

COPY $ODMDOCKERDIR/common/script $SCRIPT
RUN chmod -R a+x $SCRIPT && \
    sync && \
	  if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

# Decision Center
RUN mkdir -p $APPS && apt-get update && apt-get install unzip
COPY ./teamserver/applicationservers/WLP*/teamserver-dbdump.war $APPS/
COPY ./teamserver/applicationservers/WLP*/decision*.war $APPS/

RUN $SCRIPT/extractApp.sh decisioncenter.war && \
    if [ -s "/config/apps/decisionmodel.war" ]; then $SCRIPT/extractApp.sh decisionmodel.war; fi && \
    $SCRIPT/extractApp.sh decisioncenter-api.war && \
	  mkdir -p $APPS/decisioncenter.war/WEB-INF/classes/config
RUN $SCRIPT/changeParamValue.sh com.ibm.rules.decisioncenter.setup.configuration-file \.\\/config\\/decisioncenter-configuration.properties \\/config\\/decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/web.xml
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
COPY --chown=1001:0 $ODMDOCKERDIR/decisioncenter/config /config
COPY --chown=1001:0 $ODMDOCKERDIR/decisioncenter/script $SCRIPT
COPY --chown=1001:0 $ODMDOCKERDIR/common/config /config

COPY --chown=1001:0 $ODMDOCKERDIR/common/config/jvm/jvm.options /config/configDropins/overrides/jvm.options

COPY --chown=1001:0 $ODMDOCKERDIR/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/keystore.jks /config/security/keystore.jks
COPY --chown=1001:0 $ODMDOCKERDIR/common/security/truststore.jks /config/security/truststore.jks

COPY --chown=1001:0 $ODMDOCKERDIR/common/drivers /config/resources
RUN openssl s_client -connect www.ibm.com:443 < /dev/null 2>/dev/null | openssl x509 -outform pem > /config/resources/ibm-public.crt && chown 1001:0 /config/resources/ibm-public.crt && \
chmod -R 777 /config
RUN sed -i 's|# Pass on to the real server run|. /script/rundc.sh|' /opt/ibm/helpers/runtime/docker-server.sh && $SCRIPT/generateVersionFile.sh

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
LABEL product-version=${ODMVERSION}
LABEL product-id="IBM Operational Decision Manager for production"
LABEL io.openshift.tags="odm,dba,dbamc"

ENV APP_NAME DecisionCenter
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps

COPY --from=oidc-liberty-builder /opt/ibm/wlp /opt/ibm/wlp
COPY --from=oidc-liberty-builder /opt/ibm/helpers/runtime/docker-server.sh /opt/ibm/helpers/runtime/docker-server.sh
COPY --from=oidc-liberty-builder /opt/ibm/version.txt /opt/ibm/version.txt
# Welcome page
COPY --from=builder --chown=1001:0 /welcomepage/target/welcomepage.war $APPS


# Copy Artifact
COPY --from=builder --chown=1001:0 $APPS $APPS
COPY --from=builder --chown=1001:0 /config/resources/postgres*  /config/resources
COPY --from=builder --chown=1001:0 $SCRIPT $SCRIPT

# License
COPY --from=builder  --chown=1001:0 /licenses /licenses
USER 1001
EXPOSE 9060 9453
