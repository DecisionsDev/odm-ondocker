FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
LABEL ProductID="xxxxxxxxxxxxxxxxx"
LABEL ProductName="IBM Operational Decision Manager"
LABEL ProductVersion=$ODMVERSION
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

ENV APP_NAME DecisionRunner
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV CONNECTION_POOL_SIZE 20
ENV SCRIPT /script
ENV APPS /config/apps

RUN mkdir /config/resources && \
	mkdir -p $SCRIPT

COPY $ODMDOCKERDIR/decisionserver/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionrunner/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionrunner/script $SCRIPT
COPY $ODMDOCKERDIR/common/security /config/resources/security
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources

COPY ./executionserver/applicationservers/WLP855/DecisionRunner.war $APPS

RUN chmod -R a+x $SCRIPT && \
    sync && \
    if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

RUN $SCRIPT/extractApp.sh DecisionRunner.war

RUN /opt/ibm/wlp/bin/installUtility install concurrent-1.0 --acceptLicense

RUN $SCRIPT/changeParamValue.sh ForceDatabaseTableCreation false true $APPS/DecisionRunner.war/WEB-INF/web.xml

EXPOSE 9080 9443

CMD ["/script/rundr.sh"]
