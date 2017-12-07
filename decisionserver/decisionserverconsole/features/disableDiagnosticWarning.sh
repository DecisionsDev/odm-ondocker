#!/bin/bash

echo "running disableDiagnosticWarning.sh"

perl -i -p0e 's/(<param-name>onDocker<\/param-name>.*?<param-value>)(false)(<\/param-value>)/\1true\3/s' /config/apps/res.war/WEB-INF/web.xml
