FROM alpine:3.6 AS builder
ARG ODMDOCKERDIR
COPY $ODMDOCKERDIR/databases/postgresql/script/rundb.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/rundb.sh

FROM postgres:9.6

LABEL maintainer="Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"
MAINTAINER "Rachel ORTI <rachel.orti@fr.ibm.com>, ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com"

ARG ODMDOCKERDIR

ADD $ODMDOCKERDIR/databases/postgresql/data.tar.gz /upload
COPY --from=builder /usr/local/bin/rundb.sh  /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/rundb.sh"]

CMD ["postgres"]
