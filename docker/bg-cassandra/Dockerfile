FROM cassandra:latest
COPY share/schema.cql /tmp/schema.cql
RUN cassandra -R \
    && while [ $(cqlsh -e "USE system" || echo 1) ]; do sleep 0.5; done \
    && cqlsh</tmp/schema.cql
