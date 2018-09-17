FROM tomcat:8.5.21
ARG ODMDOCKERDIR
ARG ODMVERSION
ARG ODMDBVERSION
LABEL maintainer="Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
LABEL ProductID="xxxxxxxxxxxxxxxxx"
LABEL ProductName="Operational Decision Manager"
LABEL ProductVersion=$ODMVERSION
MAINTAINER "Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"

ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV APP_NAME StandaloneOdmOnTomcat
ENV SCRIPT $CATALINA_HOME/script
ENV APPS $CATALINA_HOME/webapps

RUN mkdir -p $SCRIPT && \
	mkdir -p $CATALINA_HOME/dbdata

COPY ${ODMDOCKERDIR}/standalone-tomcat/config ${CATALINA_HOME}/conf
COPY ${ODMDOCKERDIR}/standalone-tomcat/script $SCRIPT
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/features $SCRIPT

RUN chmod -R a+x $SCRIPT

# Begin - Configuration for the database
ENV DERBY_URL http://archive.apache.org/dist/db/derby/db-derby-10.12.1.1/db-derby-10.12.1.1-bin.tar.gz
ENV DERBY_FOLDER db-derby-10.12.1.1-bin
RUN wget -nv $DERBY_URL && \
    tar xzf ${DERBY_FOLDER}.tar.gz && \
    rm -rf ${DERBY_FOLDER}.tar.gz && \
    cp ${DERBY_FOLDER}/lib/derby.jar ${CATALINA_HOME}/lib && \
    cp ${DERBY_FOLDER}/lib/derbyLocale* ${CATALINA_HOME}/lib && \
    rm -rf ${DERBY_FOLDER}
# End - Configuration for the database

ENV CONNECTION_POOL_SIZE 20

# Sample DB
ADD ${ODMDOCKERDIR}/standalone-tomcat/data-$ODMDBVERSION.tar.gz ${CATALINA_HOME}/upload/

# Remove existing web applications
RUN rm -rf $APPS/*

# Decision Center
COPY ./teamserver/applicationservers/tomcat8/teamserver.war $APPS
COPY ./teamserver/applicationservers/tomcat8/decision*.war $APPS/

RUN $SCRIPT/extractApp.sh decisioncenter.war decisioncenter && \
    $SCRIPT/extractApp.sh decisionmodel.war decisionmodel && \
    $SCRIPT/extractApp.sh teamserver.war teamserver && \
    mkdir -p /$APPS/decisioncenter.war/WEB-INF/classes/config

RUN $SCRIPT/changeParamValue.sh com.ibm.rules.decisioncenter.setup.configuration-file . \\/config\\/decisioncenter-configuration.properties $APPS/decisioncenter/WEB-INF/web.xml

RUN mkdir $APPS/decisioncenter/WEB-INF/classes/config

# Decision Server Console
COPY ./executionserver/applicationservers/tomcat8/res.war $APPS
RUN $SCRIPT/extractApp.sh res.war res
RUN $SCRIPT/changeParamValue.sh autoCreateSchema false true $APPS/res/WEB-INF/web.xml

# Decision Server Runtime
COPY ./executionserver/applicationservers/tomcat8/DecisionService.war $APPS
RUN $SCRIPT/extractApp.sh DecisionService.war DecisionService

# Decision Runner
COPY ./executionserver/applicationservers/tomcat8/DecisionRunner.war $APPS
RUN $SCRIPT/extractApp.sh DecisionRunner.war DecisionRunner
RUN $SCRIPT/changeParamValue.sh ForceDatabaseTableCreation false true $APPS/DecisionRunner/WEB-INF/web.xml

RUN $SCRIPT/loadFeatures.sh $SCRIPT

VOLUME ["/usr/local/tomcat/dbdata/"]
EXPOSE 8080

CMD ["/usr/local/tomcat/script/runserver.sh"]
