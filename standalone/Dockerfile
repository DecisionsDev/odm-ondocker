ARG FROMLIBERTY
ARG FROMLIBERTYBUILD
ARG FROMDOCKERBUILD
FROM ${FROMDOCKERBUILD} AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps
ENV THIRDPARTY /thirdpartylib
RUN apk add --no-cache ca-certificates

COPY ${ODMDOCKERDIR}/decisioncenter/script ${ODMDOCKERDIR}/standalone/script ${ODMDOCKERDIR}/common/script ${ODMDOCKERDIR}/common/features ${SCRIPT}/
COPY ./executionserver/ /executionserver/
# Welcome page
COPY $ODMDOCKERDIR/welcomepage /welcomepage

# Loan Server Sample presence flag
RUN set -ex; \
    if [ -d /executionserver/samples/rulesetexecution/loan-server ]; then \
      touch /use_loan_server; \
      if [ -f /welcomepage/src/main/webapp/index.jsp ]; then \
        sed -i 's/ loan-server-hidden//g' /welcomepage/src/main/webapp/index.jsp; \
      fi; \  
    fi


RUN mkdir -p /root/.m2
COPY $ODMDOCKERDIR/settings.xml /root/.m2/
RUN cd /welcomepage; mvn clean install | grep -v 'Download.*'
RUN mkdir -p /config/dbdata /config/resources && chmod -R 777 /config/dbdata /config/resources

# Install the driver for H2 and for PostgreSQL
RUN mkdir -p /tmp && cd /tmp && curl -LRk https://h2database.com/h2-2019-03-13.zip -o h2.zip && unzip h2.zip && mv h2/bin/*.jar /config/resources/ && \
    curl -LORk https://jdbc.postgresql.org/download/postgresql-42.2.1.jar && mv postgres* /config/resources/

RUN chmod -R a+x $SCRIPT && mkdir $APPS

# Sample
COPY ${ODMDOCKERDIR}/standalone/samples/ /samples/build/

RUN set -ex; \
    if [ -f /use_loan_server ]; then \
      sed -i  's/localhost:9090/localhost:9060/g' /executionserver/samples/rulesetexecution/loan-server/src/main/webapp/index.html; \
      cd /samples/build; \
      mvn -Dxom.path=/samples/build/loan-validation-xom -Dloan.validation.server.path=/executionserver/samples/rulesetexecution/loan-server clean package | grep -v 'Download.*'; \
      cp /samples/build/loan-server/target/odm-loan-server-1.0.war $APPS; \
      $SCRIPT/extractApp.sh odm-loan-server-1.0.war; \
    fi

# Decision Center
COPY ./teamserver/applicationservers/WLP*/decision*.war ${APPS}/

RUN set -ex; \
    ${SCRIPT}/extractApp.sh decisioncenter.war; \
    ${SCRIPT}/extractApp.sh decisionmodel.war; \
    ${SCRIPT}/extractApp.sh decisioncenter-api.war; \
    mkdir -p ${APPS}/decisioncenter.war/WEB-INF/classes/config

RUN ${SCRIPT}/changeParamValue.sh com.ibm.rules.decisioncenter.setup.configuration-file \.\\/config\\/decisioncenter-configuration.properties \\/config\\/decisioncenter-configuration.properties ${APPS}/decisioncenter.war/WEB-INF/web.xml

COPY ${ODMDOCKERDIR}/standalone/config/group-security-configurations.xml ${APPS}/decisioncenter.war/WEB-INF/classes/config/group-security-configurations.xml

# Decision Server Console
COPY ./executionserver/applicationservers/WLP*/res.war ${APPS}
RUN set -ex; \
    ${SCRIPT}/extractApp.sh res.war; \
    ${SCRIPT}/changeParamValue.sh autoCreateSchema false true ${APPS}/res.war/WEB-INF/web.xml

# Decision Server Runtime
COPY ./executionserver/applicationservers/WLP*/DecisionService.war ${APPS}
RUN ${SCRIPT}/extractApp.sh DecisionService.war

# Decision Runner
COPY ./executionserver/applicationservers/WLP*/DecisionRunner.war ${APPS}
RUN set -ex; \
    ${SCRIPT}/extractApp.sh DecisionRunner.war; \
    ${SCRIPT}/changeParamValue.sh ForceDatabaseTableCreation false true ${APPS}/DecisionRunner.war/WEB-INF/web.xml

# Sample DB
COPY ${ODMDOCKERDIR}/standalone/resdb-8.11.1.zip ${ODMDOCKERDIR}/standalone/rtsdb-8.11.1.zip /db8111/
COPY ${ODMDOCKERDIR}/standalone/resdb-8.11.zip ${ODMDOCKERDIR}/standalone/rtsdb-8.11.zip /db811/
COPY ${ODMDOCKERDIR}/standalone/resdb-8.10.5.zip ${ODMDOCKERDIR}/standalone/rtsdb-8.10.5.zip /db8105/
ADD ${ODMDOCKERDIR}/standalone/data-8.10.3.tar.gz /db8103/
ADD ${ODMDOCKERDIR}/standalone/data-8.10.tar.gz /db810/
ADD ${ODMDOCKERDIR}/standalone/data-8.9.tar.gz /upload
# Default DB Version is 8.9 Since 8.10 there is a new DB sample with additional features.
RUN set -ex; \
    ${SCRIPT}/loadFeatures.sh ${SCRIPT}; \
    chmod -R 777 ${APPS} /upload /db810 /db8103 /db8105 /db811 /db8111 /config/dbdata

FROM ${FROMLIBERTYBUILD} AS liberty-builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR ${ODMDOCKERDIR}
USER root
ENV SCRIPT /script
ENV APPS /config/apps
COPY ${ODMDOCKERDIR}/common/script ${ODMDOCKERDIR}/wlp* /opt/wlppackage/
RUN set -ex; \
    mkdir ${SCRIPT}; \
    mv /opt/wlppackage/*.sh ${SCRIPT}; \
    $SCRIPT/installFeatures.sh

COPY --chown=1001:0 ${ODMDOCKERDIR}/standalone/licenses $APPS/licenses
COPY --chown=1001:0 ${ODMDOCKERDIR}/decisioncenter/config/application-*.xml /config/
COPY --chown=1001:0 ${ODMDOCKERDIR}/decisionserver/decisionrunner/config/application.xml /config/decisionrunner_application.xml
COPY --chown=1001:0 ${ODMDOCKERDIR}/decisionserver/decisionserverconsole/config/application.xml /config/decisionserverconsole_application.xml
COPY --chown=1001:0 ${ODMDOCKERDIR}/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY --chown=1001:0 ${ODMDOCKERDIR}/common/security/keystore.jks /config/security/keystore.jks
COPY --chown=1001:0 ${ODMDOCKERDIR}/common/security/truststore.jks /config/security/truststore.jks
COPY --chown=1001:0 ${ODMDOCKERDIR}/standalone/config /config
COPY --chown=1001:0 ${ODMDOCKERDIR}/common/config/jvm/jvm.options /config/configDropins/overrides/jvm.options

RUN chmod -R 777 /config

FROM ${FROMLIBERTY}
ARG ODMDOCKERDIR
ARG ODMVERSION
ARG ODMDBVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
MAINTAINER "Laurent GRATEAU <laurent.grateau@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"

ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV APP_NAME StandaloneOdm
ENV SCRIPT /script
ENV APPS /config/apps

# Install require Liberty features
COPY --from=liberty-builder /opt/ibm/wlp /opt/ibm/wlp

COPY --from=builder --chown=1001:0 /config/dbdata /config
ENV CONNECTION_POOL_SIZE 20

# Sample DB
COPY --from=builder --chown=1001:0 /upload/* /upload/

# Welcome page
COPY --from=builder --chown=1001:0 /welcomepage/target/welcomepage.war $APPS
COPY --from=builder --chown=1001:0 /config/resources/postgres*  /config/resources
COPY --from=builder --chown=1001:0 /config/resources/h2*  /config/resources
COPY --from=builder --chown=1001:0 ${APPS} ${APPS}
COPY --from=builder --chown=1001:0 ${SCRIPT} ${SCRIPT}
# VOLUME ["/config/dbdata/"]
USER 1001
EXPOSE 9060 9453

ENTRYPOINT ["/script/runserver.sh"]
CMD ["/script/runserver.sh"]
