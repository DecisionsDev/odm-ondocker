FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
LABEL ProductID="xxxxx"
LABEL ProductName="Operational Decision Manager"
LABEL ProductVersion="8.9.1"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>
ENV APP_NAME DecisionServerConsole
ENV ODMDOCKERDIR $ODMDOCKERDIR

ENV SCRIPT /script

RUN mkdir -p $SCRIPT && \
	mkdir -p /config/resources && \
  mkdir -p /config/apps/extract

COPY $ODMDOCKERDIR/decisionserver/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionserverconsole/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionserverconsole/script $SCRIPT
COPY $ODMDOCKERDIR/common/security /config/resources/security
COPY $ODMDOCKERDIR/common/script $SCRIPT

COPY ./executionserver/applicationservers/WLP855/res.war /config/apps/

RUN chmod -R a+x $SCRIPT && \
    sync && \
    $SCRIPT/installPostgres.sh && \
    cd /config/apps/extract && \
    unzip -q ../res.war && \
    cd ../ && \
    rm -rf res.war && \
    mv extract res.war && \
    sed -i 's/<param-value>jmx<\/param-value>/<param-value>tcpip<\/param-value>/g' /config/apps/res.war/WEB-INF/web.xml && \
    perl -i -p0e 's/(<param-name>autoCreateSchema<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/res.war/WEB-INF/web.xml && \
    perl -i -p0e 's/(<param-name>onDocker<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/res.war/WEB-INF/web.xml

EXPOSE 9080 9443 1883

CMD ["/script/runds.sh"]
