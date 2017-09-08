FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV APP_NAME DecisionRunner
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV CONNECTION_POOL_SIZE 20
ENV SCRIPT /script
RUN mkdir /config/resources && \
	mkdir -p $SCRIPT && \
	mkdir -p /config/apps/extract

COPY $ODMDOCKERDIR/decisionserver/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionrunner/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionrunner/script $SCRIPT
COPY $ODMDOCKERDIR/common/config/security /config/resources/security

# Begin - Configuration for the database
ARG DRIVER_URL
ENV DRIVER_URL $DRIVER_URL

RUN wget $DRIVER_URL && \
    case $DRIVER_URL in \
      *derby* ) mv derby* /config/resources && mv /config/datasource-derby.xml /config/datasource.xml ;; \
      *postgresql* ) mv postgresql* /config/resources ;; esac
# End - Configuration for the database

COPY ./executionserver/applicationservers/WLP855/DecisionRunner.war /config/apps/

RUN cd /config/apps/extract && \
    unzip ../DecisionRunner.war && \
	cd ../ && \
    rm -rf DecisionRunner.war && \
    mv extract DecisionRunner.war && \
    /opt/ibm/wlp/bin/installUtility install concurrent-1.0 --acceptLicense && \
    cd /config/apps/DecisionRunner.war && \
    chmod -R a+x $SCRIPT
RUN    perl -i -p0e 's/(<param-name>ForceDatabaseTableCreation<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/DecisionRunner.war/WEB-INF/web.xml

EXPOSE 9080 9443

CMD ["/script/rundr.sh"]
