FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
ARG ODMVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
LABEL ProductID="xxxxxxxxxxxxxxxxx"
LABEL ProductName="IBM Operational Decision Manager"
LABEL ProductVersion=$ODMVERSION
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

ENV APP_NAME DecisionCenter
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script
ENV APPS /config/apps

RUN mkdir /config/resources && \
    mkdir -p $SCRIPT

COPY $ODMDOCKERDIR/decisioncenter/config /config
COPY $ODMDOCKERDIR/common/security /config/resources/security
COPY $ODMDOCKERDIR/decisioncenter/script $SCRIPT
COPY $ODMDOCKERDIR/common/script $SCRIPT
COPY $ODMDOCKERDIR/common/drivers /config/resources

COPY ./teamserver/applicationservers/WLP855/teamserver.war $APPS
COPY ./teamserver/applicationservers/WLP855/decisioncenter*.war $APPS

RUN chmod -R a+x $SCRIPT && \
    sync && \
	  if [ ! -f /config/resources/postgres* ]; then $SCRIPT/installPostgres.sh; fi

RUN $SCRIPT/extractApp.sh decisioncenter.war && \
    $SCRIPT/extractApp.sh teamserver.war && \
	  mkdir -p /$APPS/decisioncenter.war/WEB-INF/classes/config

RUN $SCRIPT/changeParamValue.sh com.ibm.rules.decisioncenter.setup.configuration-file . \\/config\\/decisioncenter-configuration.properties /$APPS/decisioncenter.war/WEB-INF/web.xml

COPY $ODMDOCKERDIR/decisioncenter/decisioncenter-configuration.properties /$APPS/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
COPY $ODMDOCKERDIR/decisioncenter/ldap-configurations.xml /$APPS/decisioncenter.war/WEB-INF/classes/config/ldap-configurations.xml
COPY $ODMDOCKERDIR/decisioncenter/default-ldap-configurations.xml $APPS/decisioncenter.war/WEB-INF/classes/config/default-ldap-configurations.xml
COPY $ODMDOCKERDIR/decisioncenter/group-security-configurations.xml /$APPS/decisioncenter.war/WEB-INF/classes/config/group-security-configurations.xml

EXPOSE 9060 9443

CMD ["/script/rundc.sh"]
