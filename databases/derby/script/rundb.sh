#!/bin/bash
if [ ! -f /config/initialized.flag ] ; then
	if [ "$SAMPLE" = "true" ] ; then
		cp -R /upload/* /dbs/
	fi;
	touch /config/initialized.flag
fi;

/db-derby-10.12.1.1-bin/bin/NetworkServerControl start -h 0.0.0.0 -p 1527