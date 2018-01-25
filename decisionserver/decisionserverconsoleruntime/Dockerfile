FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
LABEL ProductID="xxxxxxxxxxxxxxxxx"
LABEL ProductName="IBM Operational Decision Manager"
LABEL ProductVersion=$ODMVERSION
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com

ENV APP_NAME DecisionServerConsoleRuntime
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps
ENV CONNECTION_POOL_SIZE 20

RUN mkdir -p $SCRIPT && \
		mkdir -p /config/resources

COPY $ODMDOCKERDIR/decisionserver/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionserverconsoleruntime/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionserverconsole/script $SCRIPT
COPY $ODMDOCKERDIR/decisionserver/decisionserverruntime/script $SCRIPT
COPY $ODMDOCKERDIR/decisionserver/decisionserverconsoleruntime/script $SCRIPT
COPY $ODMDOCKERDIR/common/config /config
COPY $ODMDOCKERDIR/common/security /config/resources/security
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources
COPY $ODMDOCKERDIR/common/features $SCRIPT

COPY ./executionserver/applicationservers/WLP855/res.war $APPS
COPY ./executionserver/applicationservers/WLP855/DecisionService.war $APPS

RUN chmod -R a+x $SCRIPT && \
    sync && \
    if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

RUN $SCRIPT/extractApp.sh res.war
RUN $SCRIPT/extractApp.sh DecisionService.war

RUN $SCRIPT/changeParamValue.sh management.protocol jmx tcpip $APPS/res.war/WEB-INF/web.xml && \
		$SCRIPT/changeParamValue.sh autoCreateSchema false true $APPS/res.war/WEB-INF/web.xml

RUN $SCRIPT/loadFeatures.sh $SCRIPT

EXPOSE 9080 9443 1883

CMD ["/script/run.sh"]
