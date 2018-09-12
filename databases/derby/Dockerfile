# Pull base image.
FROM java:7
ARG ODMDOCKERDIR
ARG ODMDBVERSION
LABEL maintainer="ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>"
MAINTAINER ODMDev odmdev_open_source_user@wwpdl.vnet.ibm.com, Laurent GRATEAU <laurent.grateau@fr.ibm.com>

# Retrieve Recent zip file from H2 site
ENV DERBY_INSTALL=/db-derby-10.12.1.1-bin
ENV DERBY_HOME=/db-derby-10.12.1.1-bin
ENV CLASSPATH=/$DERBY_INSTALL/lib/derby.jar:$DERBY_INSTALL/lib/derbytools.jar:.
ENV DOWNLOAD=http://archive.apache.org/dist/db/derby/db-derby-10.12.1.1/db-derby-10.12.1.1-bin.tar.gz
ENV DERBY_INSTALL=/opt/db-derby-10.12.1.1-bin
ENV CLASSPATH=/$DERBY_INSTALL/lib/derby.jar:$DERBY_INSTALL/lib/derbytools.jar:.


RUN \
apt-get update &&\
	apt-get install -y  wget supervisor   &&\
	wget -nv $DOWNLOAD &&\
	tar xzf db-derby-10.12.1.1-bin.tar.gz &&\
	rm -Rf /db-derby-10.12.1.1-bin.tar.gz &&\
	mkdir -p /dbs &&\
	mkdir -p /dbbackup &&\
	mkdir -p /upload &&\
	rm -rf /var/lib/apt/lists/*

ADD $ODMDOCKERDIR/databases/derby/data-$ODMDBVERSION.tar.gz /upload/
COPY $ODMDOCKERDIR/databases/derby/script/rundb.sh /db-derby-10.12.1.1-bin/bin/
RUN \
	rm -Rf /etc/supervisor/supervisord.conf &&\
	chmod a+x /db-derby-10.12.1.1-bin/bin/rundb.sh &&\
	touch /etc/supervisor.conf &&\
	echo "[supervisord]" >> /etc/supervisor.conf &&\
	echo "user=root" >> /etc/supervisor.conf &&\
	echo "nodaemon=true" >> /etc/supervisor.conf &&\
	echo "[rpcinterface:supervisor]" >> /etc/supervisor.conf &&\
	echo "supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface" >> /etc/supervisor.conf &&\
	echo "[unix_http_server]" >> /etc/supervisor.conf &&\
	echo "file=/var/run/supervisor.sock" >> /etc/supervisor.conf &&\
	echo "chmod=0700  " >> /etc/supervisor.conf &&\
	echo "[supervisorctl]" >> /etc/supervisor.conf &&\
	echo serverurl=unix:///var/run/supervisor.sock >> /etc/supervisor.conf &&\
	echo "[program:derbydb]" >> /etc/supervisor.conf &&\
	echo "command=/bin/bash -c \"cd /dbs && /db-derby-10.12.1.1-bin/bin/rundb.sh\"" >> /etc/supervisor.conf &&\
	echo "stopwaitsecs=30" >> /etc/supervisor.conf &&\
	echo "stopsignal=KILL" >> /etc/supervisor.conf &&\
	echo "killasgroup=true" >> /etc/supervisor.conf
VOLUME ["/dbs"]
EXPOSE 1527
CMD supervisord -c /etc/supervisor.conf
