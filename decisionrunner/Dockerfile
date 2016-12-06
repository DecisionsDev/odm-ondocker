FROM websphere-liberty:8.5.5.9-webProfile7

MAINTAINER Laurent GRATEAU <laurent.grateau@fr.ibm.com>
ENV APP_NAME DecisionRunner
ENV CONNECTION_POOL_SIZE 20
ENV SCRIPT /script
RUN mkdir /config/resources && \
	mkdir -p $SCRIPT && \
	mkdir -p /config/apps/extract
COPY ./docker-compose/decisionrunner/script $SCRIPT
COPY ./docker-compose/decisionrunner/server.xml /config/
COPY ./docker-compose/dbdriver/derbyclient.jar /config/resources
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

EXPOSE 9080

CMD ["/script/rundr.sh"]
