FROM tomcat:8.5.21
ARG ODMDOCKERDIR
LABEL maintainer="Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
MAINTAINER "Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV APP_NAME StandaloneOdmOnTomcat
ENV SCRIPT $CATALINA_HOME/script
RUN mkdir -p $SCRIPT && \
	mkdir -p $CATALINA_HOME/dbdata

COPY ${ODMDOCKERDIR}/standalone-tomcat/config ${CATALINA_HOME}/conf
COPY ${ODMDOCKERDIR}/standalone-tomcat/script $SCRIPT
RUN chmod -R a+x $SCRIPT

# Begin - Configuration for the database
ENV DERBY_URL http://www-eu.apache.org/dist//db/derby/db-derby-10.12.1.1/db-derby-10.12.1.1-bin.tar.gz
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
    mkdir -p ${CATALINA_HOME}/webapps/decisioncenter/WEB-INF/classes/config && \
    perl -i -p0e 's/(<param-name>com\.ibm\.rules\.decisioncenter\.setup\.configuration-file<\/param-name>.*?<param-value>)(.*?)(<\/param-value>)/\1\/config\/decisioncenter-configuration\.properties\3/s' ${CATALINA_HOME}/webapps/decisioncenter/WEB-INF/web.xml
COPY ${ODMDOCKERDIR}/standalone-tomcat/decisioncenter-configuration.properties ${CATALINA_HOME}/webapps/decisioncenter/WEB-INF/classes/config/decisioncenter-configuration.properties

# Decision Server Console
COPY ./executionserver/applicationservers/tomcat8/res.war ${CATALINA_HOME}/webapps/
RUN mkdir -p ${CATALINA_HOME}/webapps/extract && \
    cd ${CATALINA_HOME}/webapps/extract && \
    unzip -q ../res.war && \
    cd ../ && \
    rm -rf res.war && \
    mv extract res && \
    perl -i -p0e 's/(<param-name>autoCreateSchema<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' ${CATALINA_HOME}/webapps/res/WEB-INF/web.xml && \
    perl -i -p0e 's/(<param-name>onDocker<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' ${CATALINA_HOME}/webapps/res/WEB-INF/web.xml

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
    mv extract DecisionRunner && \
    perl -i -p0e 's/(<param-name>ForceDatabaseTableCreation<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' ${CATALINA_HOME}/webapps/DecisionRunner/WEB-INF/web.xml

VOLUME ["/usr/local/tomcat/dbdata/"]
EXPOSE 8080

CMD ["/usr/local/tomcat/script/runserver.sh"]
