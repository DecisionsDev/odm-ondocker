ARG FROMPOSTGRES
ARG POSTGRESUID
ARG FROMDOCKERBUILD

FROM ${FROMDOCKERBUILD} AS builder
ARG ODMDOCKERDIR
ARG ODMDBVERSION
ARG CP4BAVERSION
ARG ODMVERSION
ENV ODMDOCKERDIR $ODMDOCKERDIR
ENV CP4BAVERSION $CP4BAVERSION
ENV ODMVERSION $ODMVERSION
RUN echo "Using this ID to build the Postgresql image : ${POSTGRESUID} ${FROMPOSTGRES}"

COPY $ODMDOCKERDIR/databases/postgresql/script/ /usr/local/bin
COPY $ODMDOCKERDIR/licenses /licenses
# Manage License
COPY $ODMDOCKERDIR/databases/postgresql/script/restore.sh /tmp
COPY $ODMDOCKERDIR/common/script//generateVersionFile.sh /tmp
RUN rm -rf /licenses/.gitignore || true
RUN chmod 755 /usr/local/bin/*.sh /tmp/restore.sh /tmp/generateVersionFile.sh && mkdir /opt/ibm && /tmp/generateVersionFile.sh

COPY $ODMDOCKERDIR/databases/postgresql/data-${ODMDBVERSION}.dump /upload/data.dump
COPY $ODMDOCKERDIR/databases/postgresql/*.sql /upload/
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
LABEL product-version=${ODMVERSION}
LABEL product-id="IBM Operational Decision Manager for production"
LABEL io.openshift.tags="odm,dba,dbamc"


COPY --from=builder --chown=999:999 /upload /upload
COPY --from=builder --chown=999:999 /opt/ibm /opt/ibm

COPY --from=builder --chown=999:999 /usr/local/bin/*db.sh  /usr/local/bin/
COPY --from=builder --chown=999:999 /tmp/restore.sh  /opt/app-root/src/postgresql-start/restore.sh
COPY --from=builder --chown=999:999 /tmp/restore.sh  /docker-entrypoint-initdb.d/restore.sh
# License
COPY --from=builder  --chown=999:0 /licenses /licenses
COPY --from=builder  --chown=999:0 /licenses /licenses
USER 999
ENTRYPOINT ["/usr/local/bin/rundb.sh"]

CMD ["postgres"]
