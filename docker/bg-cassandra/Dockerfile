FROM cassandra:3.11.3
RUN cassandra -R \
    && while [ $(cqlsh -e "USE biggraphite" || echo 1) ]; do sleep 0.5; cqlsh -e "CREATE KEYSPACE IF NOT EXISTS biggraphite WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};"; done \
    && echo "biggraphite keyspace created" \
    && cqlsh -e "DESCRIBE biggraphite" \
    && sleep 1
