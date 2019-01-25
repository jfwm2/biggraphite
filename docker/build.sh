#!/bin/bash

AGG_CONF=volumes_graphite-aggregator-cache/conf
WEB_CONF=volumes_graphite-web/conf

for i in $(ls */Dockerfile | sed 's/\(.*\)\/.*/\1/');
do
 mkdir -p volumes_${i}  
 docker build .. -t ${i} -f ${i}/Dockerfile
done

mkdir -p ${AGG_CONF} ${WEB_CONF}

cat << EOF > ${AGG_CONF}/carbon.conf
[cache]
BG_DATA_DRIVER = cassandra
BG_METADATA_DRIVER = elasticsearch
DATABASE = biggraphite
BG_CASSANDRA_KEYSPACE = biggraphite
BG_CASSANDRA_CONTACT_POINTS = cassandra
BG_CASSANDRA_CONTACT_POINTS_METADATA =
BG_CACHE = memory
STORAGE_DIR = /tmp
BG_ELASTICSEARCH_HOSTS = elasticsearch
BG_ELASTICSEARCH_PORT = 9200
#BG_ELASTICSEARCH_INDEX_SUFFIX = _%Y-w%W
EOF

touch ${AGG_CONF}/storage-schemas.conf

cat << EOF > ${WEB_CONF}/local_settings.py
DEBUG = True
LOG_DIR = '/tmp'
STORAGE_DIR = '/tmp'
STORAGE_FINDERS = ['biggraphite.plugins.graphite.Finder']
TAGDB = 'biggraphite.plugins.tags.BigGraphiteTagDB'
# Cassandra configuration
BG_CASSANDRA_KEYSPACE = 'biggraphite'
BG_CASSANDRA_CONTACT_POINTS = 'cassandra'
BG_DATA_DRIVER = 'cassandra'
BG_CACHE = 'memory'
WEBAPP_DIR = '/usr/local/webapp/'
## Elasticsearch configuration
BG_METADATA_DRIVER = 'elasticsearch'
BG_ELASTICSEARCH_HOSTS = 'elasticsearch'
BG_ELASTICSEARCH_PORT = '9200'
EOF

cat << EOF > ${WEB_CONF}/launch-graphite-web.sh
#! /bin/bash

cp /conf/local_settings.py /usr/local/lib/python3.6/site-packages/graphite/
export DJANGO_SETTINGS_MODULE=graphite.settings
django-admin migrate
django-admin migrate --run-syncdb
cd /usr/local/lib/python3.6/site-packages/graphite && run-graphite-devel-server.py /usr/local
EOF
