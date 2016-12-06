FROM websphere-liberty:8.5.5.9-webProfile7

MAINTAINER Laurent GRATEAU <laurent.grateau@fr.ibm.com>
ENV APP_NAME DecisionCenter
RUN mkdir /config/resources 
#COPY ./docker-compose/decisioncenter/script $SCRIPT
COPY ./docker-compose/decisioncenter/server.xml /config/
COPY ./docker-compose/dbdriver/derbyclient.jar /config/resources

COPY ./teamserver/lib/commons-logging-1.1.jar /config/lib/
COPY ./teamserver/applicationservers/WLP855/teamserver.war /config/apps/
COPY ./teamserver/applicationservers/WLP855/decisioncenter.war /config/apps/

EXPOSE 9060

