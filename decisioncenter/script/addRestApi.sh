#!/bin/bash

applicationXml=$1

if [ ! $applicationXml ]; then
  applicationXml="application.xml"
fi

# Begin - Add DC Rest Api Web App
if [ -e $APPS/decisioncenter-api.war ]
then
    if [ -e $APPS/teamserver-dbdump.war ]
    then
        echo "Add DC Rest Api Web App & DBDump in $applicationXml"
        cp -f /config/application-withRestApi-withDBDump.xml /config/$applicationXml
    else
        echo "Add DC Rest Api Web App in $applicationXml"
        cp -f /config/application-withRestApi.xml /config/$applicationXml
    fi
else
        echo "DC Rest Api Web App is not present"
fi
# End - Add DC Rest Api Web App
