FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
LABEL ProductID="xxxxx"
LABEL ProductName="Operational Decision Manager"
LABEL ProductVersion="8.9.1"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>
ENV APP_NAME DecisionCenter
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV SCRIPT /script

RUN mkdir /config/resources && \
  mkdir -p $SCRIPT

COPY $ODMDOCKERDIR/decisioncenter/config /config
COPY $ODMDOCKERDIR/common/security /config/resources/security
COPY $ODMDOCKERDIR/decisioncenter/script $SCRIPT
COPY $ODMDOCKERDIR/common/script $SCRIPT

COPY ./teamserver/lib/commons-logging-1.1.jar /config/lib/
COPY ./teamserver/applicationservers/WLP855/teamserver.war /config/apps/
COPY ./teamserver/applicationservers/WLP855/decisioncenter.war /config/apps/

RUN chmod -R a+x $SCRIPT && \
	$SCRIPT/defaultInstall.sh && \
	mkdir -p /config/apps/extract && \
	cd /config/apps/extract && \
    unzip -q ../decisioncenter.war && \
	cd ../ && \
    rm -rf decisioncenter.war && \
    mv extract decisioncenter.war && \
    mkdir -p /config/apps/extract && \
	cd /config/apps/extract && \
    unzip -q ../teamserver.war && \
	cd ../ && \
    rm -rf teamserver.war && \
    mv extract teamserver.war && \
	mkdir -p /config/apps/decisioncenter.war/WEB-INF/classes/config && \
	perl -i -p0e 's/(<param-name>com\.ibm\.rules\.decisioncenter\.setup\.configuration-file<\/param-name>.*?<param-value>)(.*?)(<\/param-value>)/\1\/config\/decisioncenter-configuration\.properties\3/s' /config/apps/decisioncenter.war/WEB-INF/web.xml

COPY $ODMDOCKERDIR/decisioncenter/decisioncenter-configuration.properties /config/apps/decisioncenter.war/WEB-INF/classes/config/decisioncenter-configuration.properties
COPY $ODMDOCKERDIR/decisioncenter/ldap-configurations.xml /config/apps/decisioncenter.war/WEB-INF/classes/config/ldap-configurations.xml
COPY $ODMDOCKERDIR/decisioncenter/group-security-configurations.xml /config/apps/decisioncenter.war/WEB-INF/classes/config/group-security-configurations.xml

EXPOSE 9060 9443

CMD ["/script/rundc.sh"]
