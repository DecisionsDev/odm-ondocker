FROM websphere-liberty:webProfile7
ARG ODMDOCKERDIR
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>
ENV SCRIPT /script
ENV ODMDOCKERDIR $ODMDOCKERDIR
RUN \
	mkdir -p $SCRIPT && \
	mkdir -p /config/resources
	
COPY $ODMDOCKERDIR/decisionserver/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionserverconsole/config /config
COPY $ODMDOCKERDIR/decisionserver/decisionserverconsole/script $SCRIPT
COPY $ODMDOCKERDIR/common/config/security /config/resources/security
ADD $ODMDOCKERDIR/dbdriver/derbyclient.jar /config/resources
RUN mkdir -p /config/apps/res.war
COPY ./executionserver/applicationservers/WLP855/res.war /config/apps/res-file.war
RUN cd /config/apps/res.war && \
    unzip ../res-file.war && \
    rm ../res-file.war && \
    sed -i 's/<param-value>jmx<\/param-value>/<param-value>tcpip<\/param-value>/g' /config/apps/res.war/WEB-INF/web.xml && \
    chmod -R a+x $SCRIPT && \
    perl -i -p0e 's/(<param-name>autoCreateSchema<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/res.war/WEB-INF/web.xml && \
    perl -i -p0e 's/(<param-name>onDocker<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/res.war/WEB-INF/web.xml

EXPOSE 9080 9443 1883
CMD ["/script/runds.sh"]
