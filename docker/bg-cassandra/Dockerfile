FROM cassandra:latest
COPY share/schema.cql /tmp/createdb.cql
RUN cassandra -R \
    && while [ $(cqlsh -e "USE biggraphite" || echo 1) ]; do sleep 5; cqlsh</tmp/createdb.cql; done
