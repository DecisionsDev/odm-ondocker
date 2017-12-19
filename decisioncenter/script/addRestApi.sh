#!/bin/bash

# Begin - Add DC Rest Api Web App
if [ -e /config/apps/decisioncenter-api.war ]
then
        echo "Add DC Rest Api Web App"
        cp /config/application-withRestApi.xml /config/application.xml
else
        echo "DC Rest Api Web App is not present"
fi
# End - Add DC Rest Api Web App
