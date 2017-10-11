FROM osixia/openldap:1.1.9

LABEL maintainer="Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
MAINTAINER "Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"

ARG ODMDOCKERDIR

ADD $ODMDOCKERDIR/ldap/bootstrap /container/service/slapd/assets/config/bootstrap
#ADD $ODMDOCKERDIR/ldap/certs /container/service/slapd/assets/certs
#ADD $ODMDOCKERDIR/ldap/environment /container/environment/01-custom