FROM websphere-liberty:8.5.5.9-webProfile7

MAINTAINER Laurent GRATEAU <laurent.grateau@fr.ibm.com
ENV SCRIPT /script

RUN \
	mkdir -p $SCRIPT && \
	mkdir -p /config/resources
COPY ./docker-compose/decisionserverconsole/script $SCRIPT
COPY ./docker-compose/decisionserverconsole/server.xml /config/
ADD ./docker-compose/dbdriver/derbyclient.jar /config/resources
RUN mkdir -p /config/apps/res.war
COPY ./executionserver/applicationservers/WLP855/res.war /config/apps/res-file.war
RUN cd /config/apps/res.war && \ 
    unzip ../res-file.war && \
    rm ../res-file.war && \
    sed -i 's/<param-value>jmx<\/param-value>/<param-value>tcpip<\/param-value>/g' /config/apps/res.war/WEB-INF/web.xml && \
    chmod -R a+x $SCRIPT && \
    perl -i -p0e 's/(<param-name>autoCreateSchema<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/res.war/WEB-INF/web.xml 

EXPOSE 9080

CMD ["/script/runds.sh"]