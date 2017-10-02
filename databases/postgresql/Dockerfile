FROM postgres:9.5

ARG ODMDOCKERDIR

ADD $ODMDOCKERDIR/databases/postgresql/data.tar.gz /upload
COPY $ODMDOCKERDIR/databases/postgresql/script/rundb.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/rundb.sh && \
	ln -s usr/local/bin/rundb.sh rundb.sh

ENTRYPOINT ["rundb.sh"]

CMD ["postgres"]

