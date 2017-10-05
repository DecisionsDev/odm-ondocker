FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>
ENV APP_NAME DecisionCenter
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
RUN mkdir /config/resources && \
  mkdir -p $SCRIPT

COPY $ODMDOCKERDIR/decisioncenter/config /config
COPY $ODMDOCKERDIR/common/security /config/resources/security
COPY $ODMDOCKERDIR/decisioncenter/script $SCRIPT
# Begin - Configuration for the database
ARG DRIVER_URL
ENV DRIVER_URL $DRIVER_URL

RUN wget $DRIVER_URL && \
    case $DRIVER_URL in \
      *derby* ) mv derby* /config/resources && mv /config/datasource-derby.xml /config/datasource.xml ;; \
      *mysql* ) mv mysql* /config/resources && mv /config/datasource-mysql.xml /config/datasource.xml ;; \
      *postgresql* ) mv postgresql* /config/resources ;; esac
# End - Configuration for the database

COPY ./teamserver/lib/commons-logging-1.1.jar /config/lib/
COPY ./teamserver/applicationservers/WLP855/teamserver.war /config/apps/
COPY ./teamserver/applicationservers/WLP855/decisioncenter.war /config/apps/

RUN mkdir -p /config/apps/extract && \
	cd /config/apps/extract && \
    unzip ../decisioncenter.war && \
	cd ../ && \
    rm -rf decisioncenter.war && \
    mv extract decisioncenter.war && \
    mkdir -p /config/apps/extract && \
	cd /config/apps/extract && \
    unzip ../teamserver.war && \
	cd ../ && \
    rm -rf teamserver.war && \
    mv extract teamserver.war && \
    chmod -R a+x $SCRIPT && \
	mkdir -p /config/apps/decisioncenter.war/WEB-INF/classes/config && \
	perl -i -p0e 's/(<param-name>com\.ibm\.rules\.decisioncenter\.setup\.configuration-file<\/param-name>.*?<param-value>)(.*?)(<\/param-value>)/\1\/config\/decisioncenter-configuration\.properties\3/s' /config/apps/decisioncenter.war/WEB-INF/web.xml

COPY $ODMDOCKERDIR/decisioncenter/decisioncenter-configuration.properties /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties

EXPOSE 9060 9443


CMD ["/script/rundc.sh"]