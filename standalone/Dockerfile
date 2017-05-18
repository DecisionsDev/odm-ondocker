FROM websphere-liberty:8.5.5.9-webProfile7

MAINTAINER Laurent GRATEAU <laurent.grateau@fr.ibm.com>
ENV APP_NAME StandaloneOdm
ENV SCRIPT /script
RUN mkdir /config/resources && \
	mkdir -p $SCRIPT && \
	mkdir -p /config/apps/extract \
	mkdir -p /config/dbdata


COPY ./docker-compose/standalone/server.xml /config/
COPY ./docker-compose/dbdriver/derby-10*.jar /config/resources
COPY ./docker-compose/standalone/script $SCRIPT

ENV CONNECTION_POOL_SIZE 20
ENV SCRIPT /script
RUN chmod -R a+x $SCRIPT

# Sample DB 
ADD ./docker-compose/derby-server-db/data.tar.gz /upload/

# Decision Center
COPY ./teamserver/lib/commons-logging-1.1.jar /config/lib/
COPY ./teamserver/applicationservers/WLP855/teamserver.war /config/apps/
COPY ./teamserver/applicationservers/WLP855/decisioncenter.war /config/apps/

# Decision Server Console
RUN mkdir -p /config/apps/res.war
COPY ./executionserver/applicationservers/WLP855/res.war /config/apps/res-file.war
RUN cd /config/apps/res.war && \ 
    unzip ../res-file.war && \
    rm ../res-file.war && \
    chmod -R a+x $SCRIPT && \
    perl -i -p0e 's/(<param-name>autoCreateSchema<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/res.war/WEB-INF/web.xml

# Decision Server Runtime
COPY ./executionserver/applicationservers/WLP855/DecisionService.war /config/apps/
RUN cd /config/apps/extract && \ 
    unzip ../DecisionService.war && \
	cd ../ && \
    rm -rf DecisionService.war && \
    mv extract DecisionService.war && \
    cd /config/apps/DecisionService.war 

# Decision Runner
COPY ./executionserver/applicationservers/WLP855/DecisionRunner.war /config/apps/
RUN mkdir -p /config/apps/extract && \ 
    cd /config/apps/extract && \ 
    unzip ../DecisionRunner.war && \
	cd ../ && \
    rm -rf DecisionRunner.war && \
    mv extract DecisionRunner.war && \
    /opt/ibm/wlp/bin/installUtility install concurrent-1.0 --acceptLicense && \
    cd /config/apps/DecisionRunner.war && \
    chmod -R a+x $SCRIPT
RUN    perl -i -p0e 's/(<param-name>ForceDatabaseTableCreation<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/DecisionRunner.war/WEB-INF/web.xml

EXPOSE 9080

CMD ["/script/runserver.sh"]
