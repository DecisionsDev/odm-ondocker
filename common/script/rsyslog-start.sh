#!/bin/bash

export ZENAUDITURL="zen-audit-svc.$(echo $NAMESPACE).svc.cluster.local"
rsyslogd -dn -i /tmp/rsyslog.pid
