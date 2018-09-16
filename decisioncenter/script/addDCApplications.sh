#!/bin/bash

applicationXml=$1

if [ ! ${applicationXml} ]; then
  applicationXml="/config/application.xml"
fi

function addApplication {
    if [ -e "${APPS}/$1.war" ]
    then
        cat "/config/application-$1.xml" >> ${applicationXml}
    fi
}

# Begin - Add DC Apps

touch ${applicationXml}

echo "<server>" >> ${applicationXml}
cat ${applicationXml}

addApplication decisioncenter
addApplication decisionmodel
addApplication teamserver
addApplication decisioncenter-api
addApplication teamserver-dbdump

echo "</server>" >> ${applicationXml}
cat ${applicationXml}

# End - Add DC Apps
