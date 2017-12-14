FROM tomcat:8.5.21
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
LABEL ProductID="xxxxxxxxxxxxxxxxx"
LABEL ProductName="Operational Decision Manager"
LABEL ProductVersion=$ODMVERSION
MAINTAINER "Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"

ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV APP_NAME StandaloneOdmOnTomcat
ENV SCRIPT $CATALINA_HOME/script
ENV APPS /config/apps

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
ADD ${ODMDOCKERDIR}/standalone-tomcat/data.tar.gz ${CATALINA_HOME}/upload/

# Remove existing web applications
RUN cd ${CATALINA_HOME}/webapps && \
    rm -rf *

# Decision Center
COPY ./teamserver/applicationservers/tomcat8/teamserver.war ${CATALINA_HOME}/webapps/
COPY ./teamserver/applicationservers/tomcat8/decisioncenter.war ${CATALINA_HOME}/webapps/
RUN mkdir -p ${CATALINA_HOME}/webapps/extract && \
    cd ${CATALINA_HOME}/webapps/extract && \
    unzip -q ../teamserver.war && \
    cd ../ && \
    rm -rf teamserver.war && \
    mv extract teamserver && \
    mkdir -p ${CATALINA_HOME}/webapps/extract && \
    cd ${CATALINA_HOME}/webapps/extract && \
    unzip -q ../decisioncenter.war && \
    cd ../ && \
    rm -rf decisioncenter.war && \
    mv extract decisioncenter && \
    mkdir -p ${CATALINA_HOME}/webapps/decisioncenter/WEB-INF/classes/config

RUN $SCRIPT/changeParamValue.sh com.ibm.rules.decisioncenter.setup.configuration-file . \\/config\\/decisioncenter-configuration.properties /config/apps/decisioncenter.war/WEB-INF/web.xml

COPY ${ODMDOCKERDIR}/standalone-tomcat/decisioncenter-configuration.properties ${CATALINA_HOME}/webapps/decisioncenter/WEB-INF/classes/config/decisioncenter-configuration.properties

# Decision Server Console
COPY ./executionserver/applicationservers/tomcat8/res.war ${CATALINA_HOME}/webapps/
RUN mkdir -p ${CATALINA_HOME}/webapps/extract && \
    cd ${CATALINA_HOME}/webapps/extract && \
    unzip -q ../res.war && \
    cd ../ && \
    rm -rf res.war && \
    mv extract res

RUN $SCRIPT/changeParamValue.sh autoCreateSchema false true /config/apps/res.war/WEB-INF/web.xml

# Decision Server Runtime
COPY ./executionserver/applicationservers/tomcat8/DecisionService.war ${CATALINA_HOME}/webapps
RUN mkdir -p ${CATALINA_HOME}/webapps/extract && \
    cd ${CATALINA_HOME}/webapps/extract && \
    unzip -q ../DecisionService.war && \
    cd ../ && \
    rm -rf DecisionService.war && \
    mv extract DecisionService

# Decision Runner
COPY ./executionserver/applicationservers/tomcat8/DecisionRunner.war ${CATALINA_HOME}/webapps
RUN mkdir -p ${CATALINA_HOME}/webapps/extract && \
    cd ${CATALINA_HOME}/webapps/extract && \
    unzip -q ../DecisionRunner.war && \
	cd ../ && \
    rm -rf DecisionRunner.war && \
    mv extract DecisionRunner

RUN $SCRIPT/changeParamValue.sh ForceDatabaseTableCreation false true /config/apps/DecisionRunner.war/WEB-INF/web.xml

RUN $SCRIPT/loadFeatures.sh $SCRIPT

VOLUME ["/usr/local/tomcat/dbdata/"]
EXPOSE 8080

CMD ["/usr/local/tomcat/script/runserver.sh"]
