#!/bin/bash

echo "running disableDiagnosticWarning.sh"

$SCRIPT/changeParamValue.sh onDocker false true /config/apps/res.war/WEB-INF/web.xml
