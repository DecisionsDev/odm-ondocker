ARG FROMLIBERTY
FROM maven:3.5.2-jdk-8-alpine AS builder
ARG ODMDOCKERDIR
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps
ENV THIRDPARTY /thirdpartylib
RUN apk add --no-cache ca-certificates wget

COPY ${ODMDOCKERDIR}/decisioncenter/script $SCRIPT
COPY ${ODMDOCKERDIR}/standalone/script $SCRIPT
COPY ${ODMDOCKERDIR}/common/script $SCRIPT
COPY ${ODMDOCKERDIR}/common/features $SCRIPT
COPY ./executionserver/ /executionserver

# Loan Server Sample presence flag
RUN if [ -d /executionserver/samples/rulesetexecution/loan-server ]; then touch /use_loan_server; fi    

# Welcome page
COPY $ODMDOCKERDIR/welcomepage /welcomepage

RUN if [ -f /use_loan_server ]; then \
    sed -i  's/ loan-server-hidden//g' /welcomepage/src/main/webapp/index.jsp; fi
    
RUN cd /welcomepage; mvn clean install  | grep -v 'Download.*'
RUN mkdir -p /config/dbdata /config/resources && chmod -R 777 /config/dbdata /config/resources
#COPY ${ODMDOCKERDIR}/decisioncenter/config/application.xml /config/decisionrunner_application.xml

# Begin - Configuration for the database
# Install the driver for H2 and for PostgreSQL
RUN wget -nv http://central.maven.org/maven2/com/h2database/h2/1.4.196/h2-1.4.196.jar && mv h2* /config/resources && \
    wget -nv https://jdbc.postgresql.org/download/postgresql-42.2.1.jar && mv postgres* /config/resources
# End - Configuration for the database

RUN chmod -R a+x $SCRIPT && mkdir $APPS

# Sample
COPY ${ODMDOCKERDIR}/standalone/samples/ /samples/build/

RUN if [ -f /use_loan_server ]; then \
    sed -i  's/localhost:9090/localhost:9060/g' /executionserver/samples/rulesetexecution/loan-server/src/main/webapp/index.html && \
    cd /samples/build; mvn -Dxom.path=/samples/build/loan-validation-xom -Dloan.validation.server.path=/executionserver/samples/rulesetexecution/loan-server  clean package   | grep -v 'Download.*' && \
    cp /samples/build/loan-server/target/odm-loan-server-1.0.war $APPS && \
    $SCRIPT/extractApp.sh odm-loan-server-1.0.war; fi

# Decision Center
COPY ./teamserver/applicationservers/WLP*/teamserver.war $APPS
COPY ./teamserver/applicationservers/WLP*/decision*.war $APPS/

RUN $SCRIPT/extractApp.sh decisioncenter.war && \
    $SCRIPT/extractApp.sh decisionmodel.war && \
    $SCRIPT/extractApp.sh teamserver.war && \
    $SCRIPT/extractApp.sh decisioncenter-api.war && \
    mkdir -p $APPS/decisioncenter.war/WEB-INF/classes/config

RUN $SCRIPT/changeParamValue.sh com.ibm.rules.decisioncenter.setup.configuration-file \.\\/config\\/decisioncenter-configuration.properties \\/config\\/decisioncenter-configuration.properties $APPS/decisioncenter.war/WEB-INF/web.xml

COPY ${ODMDOCKERDIR}/standalone/config/group-security-configurations.xml $APPS/decisioncenter.war/WEB-INF/classes/config/group-security-configurations.xml

# Decision Server Console
COPY ./executionserver/applicationservers/WLP*/res.war $APPS
RUN $SCRIPT/extractApp.sh res.war
RUN $SCRIPT/changeParamValue.sh autoCreateSchema false true $APPS/res.war/WEB-INF/web.xml

# Decision Server Runtime
COPY ./executionserver/applicationservers/WLP*/DecisionService.war $APPS
RUN $SCRIPT/extractApp.sh DecisionService.war

# Decision Runner
COPY ./executionserver/applicationservers/WLP*/DecisionRunner.war $APPS
RUN $SCRIPT/extractApp.sh DecisionRunner.war
RUN $SCRIPT/changeParamValue.sh ForceDatabaseTableCreation false true $APPS/DecisionRunner.war/WEB-INF/web.xml
# Sample DB
ADD ${ODMDOCKERDIR}/standalone/data-8.10.tar.gz /db810/
ADD ${ODMDOCKERDIR}/standalone/data-8.9.tar.gz /upload
# Default DB Version is 8.9 Since 8.10 there is a new DB sample with additional features.
RUN $SCRIPT/loadFeatures.sh $SCRIPT && \
chmod -R 777 $APPS && \
chmod -R 777 /upload /db810 /config/dbdata



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

COPY --chown=1001:0 $ODMDOCKERDIR/standalone/licenses $APPS/licenses
COPY --chown=1001:0 ${ODMDOCKERDIR}/decisioncenter/config/application-*.xml /config/
COPY --chown=1001:0 ${ODMDOCKERDIR}/decisionserver/decisionrunner/config/application.xml /config/decisionrunner_application.xml
COPY --chown=1001:0 ${ODMDOCKERDIR}/decisionserver/decisionserverconsole/config/application.xml /config/decisionserverconsole_application.xml
COPY --chown=1001:0 ${ODMDOCKERDIR}/common/security/ltpa.keys /config/resources/security/ltpa.keys
COPY --chown=1001:0 ${ODMDOCKERDIR}/common/security/keystore.jks /config/security/keystore.jks
COPY --chown=1001:0 ${ODMDOCKERDIR}/common/security/truststore.jks /config/security/truststore.jks
COPY --chown=1001:0 ${ODMDOCKERDIR}/standalone/config /config

COPY --from=builder --chown=1001:0 /config/dbdata /config
ENV CONNECTION_POOL_SIZE 20

# Sample DB
COPY --from=builder --chown=1001:0 /upload/* /upload/

# Welcome page
COPY --from=builder --chown=1001:0 /welcomepage/target/welcomepage.war $APPS
COPY --from=builder --chown=1001:0 /config/resources/postgres*  /config/resources
COPY --from=builder --chown=1001:0 /config/resources/h2*  /config/resources
COPY --from=builder --chown=1001:0 $APPS $APPS
COPY --from=builder --chown=1001:0 $SCRIPT $SCRIPT
# VOLUME ["/config/dbdata/"]
EXPOSE 9060 9453

ENTRYPOINT ["/script/runserver.sh"]
CMD ["/script/runserver.sh"]
