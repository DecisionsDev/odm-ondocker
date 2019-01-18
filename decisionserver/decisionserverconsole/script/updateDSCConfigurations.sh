#!/bin/bash

if [ -n "$DECISION_SERVICE_URL" ]; then
	echo "Update DECISION_SERVICE_URL to $DECISION_SERVICE_URL in Decision Server Console."
	sed -i 's|/DecisionService|'$DECISION_SERVICE_URL'|g' $APPS/res.war/WEB-INF/web.xml
fi

if [ -f "/config/baiemitterconfig/plugin-configuration.properties" ]; then
	echo "Enable BAI Emitter Plugin"
	perl -i -p0e "s/({pluginClass=HTDS[^}]*)/\1},{pluginClass=ODMEmitterForBAI/gm" ra.xml;
fi
