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

addApplication decisioncenter
addApplication decisioncenter-api
addApplication teamserver-dbdump

if [ -n "$ENABLE_DECISION_ASSISTANT" ]
then
  if [[ $ENABLE_DECISION_ASSISTANT =~ "true" ]]
  then
    echo "Enabling Decision Assistant Web App"
    addApplication decision-assistant
  fi
fi

echo "</server>" >> ${applicationXml}


# End - Add DC Apps
