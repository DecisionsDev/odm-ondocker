FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>
ENV APP_NAME DecisionService
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV CONNECTION_POOL_SIZE 20
ENV SCRIPT /script
RUN mkdir /config/resources && \
	mkdir -p $SCRIPT && \
	mkdir -p /config/apps/extract

COPY $ODMDOCKERDIR/decisionserver/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionserverruntime/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionserverruntime/script $SCRIPT
COPY $ODMDOCKERDIR/common/security /config/resources/security

# Begin - Configuration for the database
ARG DRIVER_URL
ENV DRIVER_URL $DRIVER_URL

RUN wget -nv $DRIVER_URL && \
    case $DRIVER_URL in \
      *derby* ) mv derby* /config/resources && mv /config/datasource-derby.xml /config/datasource.xml ;; \
      *mysql* ) mv mysql* /config/resources && mv /config/datasource-mysql.xml /config/datasource.xml ;; \
      *postgresql* ) mv postgresql* /config/resources ;; esac
# End - Configuration for the database

COPY ./executionserver/applicationservers/WLP855/DecisionService.war /config/apps/

RUN cd /config/apps/extract && \
    unzip -q ../DecisionService.war && \
	cd ../ && \
    rm -rf DecisionService.war && \
    mv extract DecisionService.war && \
    cd /config/apps/DecisionService.war && \
    chmod -R a+x $SCRIPT
EXPOSE 9080 9443

CMD ["/script/runds.sh"]
