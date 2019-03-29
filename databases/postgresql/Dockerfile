FROM alpine:3.6 AS builder
ARG ODMDOCKERDIR
ARG ODMDBVERSION
COPY $ODMDOCKERDIR/databases/postgresql/script/rundb.sh /usr/local/bin
COPY $ODMDOCKERDIR/licenses /licenses
# Manage License
RUN rm -rf /licenses/.gitignore || true
RUN chmod a+x /usr/local/bin/rundb.sh

FROM postgres:9.6

LABEL maintainer="Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
MAINTAINER "Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"

ARG ODMDOCKERDIR
ARG ODMDBVERSION

LABEL name="DBServer"
LABEL io.k8s.display-name="DBServer"
LABEL description="The Database server stores decision service artifacts."


LABEL summary="Database server to store decisions artifacts."
LABEL io.k8s.description="Database server to store decisions artifacts."

LABEL vendor="IBM"
LABEL version=${ODMVERSION}
LABEL io.openshift.tags="odm,dba,dbamc"


ADD $ODMDOCKERDIR/databases/postgresql/data-${ODMDBVERSION}.tar.gz /upload
COPY --from=builder --chown=999:999 /usr/local/bin/rundb.sh  /usr/local/bin/
# License
COPY --from=builder  --chown=1001:0 /licenses /licenses

ENTRYPOINT ["/usr/local/bin/rundb.sh"]

CMD ["postgres"]
