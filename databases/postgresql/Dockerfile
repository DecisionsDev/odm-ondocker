ARG FROMPOSTGRES
ARG POSTGRESUID


FROM alpine:3.6 AS builder
ARG ODMDOCKERDIR
ARG ODMDBVERSION

RUN echo "Using this ID to build the Postgresql image : ${POSTGRESUID} ${FROMPOSTGRES}"

COPY $ODMDOCKERDIR/databases/postgresql/script/rundb.sh /usr/local/bin
COPY $ODMDOCKERDIR/licenses /licenses
# Manage License

RUN rm -rf /licenses/.gitignore || true
RUN chmod a+x /usr/local/bin/rundb.sh

ADD $ODMDOCKERDIR/databases/postgresql/data-${ODMDBVERSION}.tar.gz /upload

FROM ${FROMPOSTGRES}

LABEL maintainer="Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
MAINTAINER "Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"

ARG ODMDOCKERDIR
ARG ODMDBVERSION
ARG ODMVERSION
ARG POSTGRESUID
LABEL name="DBServer"
LABEL io.k8s.display-name="DBServer"
LABEL description="The Database server stores decision service artifacts."


LABEL summary="Database server to store decisions artifacts."
LABEL io.k8s.description="Database server to store decisions artifacts."

LABEL vendor="IBM"
LABEL version=${ODMVERSION}
LABEL ProductVersion=${ODMVERSION}
LABEL ProductID="IBM Operational Decision Manager for production"
LABEL io.openshift.tags="odm,dba,dbamc"



COPY --from=builder --chown=${POSTGRESUID}:${POSTGRESUID} /upload /upload

COPY --from=builder --chown=${POSTGRESUID}:${POSTGRESUID} /usr/local/bin/rundb.sh  /usr/local/bin/
# License
COPY --from=builder  --chown=${POSTGRESUID}:0 /licenses /licenses
USER ${POSTGRESUID}
ENTRYPOINT ["/usr/local/bin/rundb.sh"]

CMD ["postgres"]
