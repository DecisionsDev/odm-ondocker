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

if [ -n DECISION_MODEL_DISABLED ]
then
        if [ "$DECISION_MODEL_DISABLED" == "false" ]
        then
		echo "Add Decision Model Application"
		addApplication decisionmodel
	fi
fi
addApplication decisioncenter-api
addApplication teamserver-dbdump

echo "</server>" >> ${applicationXml}


# End - Add DC Apps
