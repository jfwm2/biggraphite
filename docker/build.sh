#! /bin/bash

AGG_CONF=volumes_graphite-aggregator-cache/conf
WEB_CONF=volumes_graphite-web/conf

build_bg-cassandra (){
  docker build bg-cassandra -t bg-cassandra -f bg-cassandra/Dockerfile
}

build_bg-elasticsearch (){
  docker build bg-elasticsearch -t bg-elasticsearch -f bg-elasticsearch/Dockerfile
}

build_bg-kibana (){
  docker build bg-kibana -t bg-kibana -f bg-kibana/Dockerfile
}

build_graphite-aggregator-cache (){
  docker build .. -t graphite-aggregator-cache -f graphite-aggregator-cache/Dockerfile

  mkdir -p ${AGG_CONF} volumes_graphite-aggregator-cache

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
}


build_graphite-web (){
  docker build .. -t graphite-web -f graphite-web/Dockerfile

  mkdir -p ${WEB_CONF} volumes_graphite-web

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
}

build (){
  case ${1} in
    bg-cassandra)
      build_bg-cassandra ;;
    bg-elasticsearch)
      build_bg-elasticsearch ;;
    bg-kibana)
      build_bg-kibana ;;
    graphite-aggregator-cache)
      build_graphite-aggregator-cache ;;
    graphite-web)
      build_graphite-web ;;
    *)
      usage ;;
  esac
}

usage (){
  echo "usage: $(basename ${0} \[dir1 \[dir2 ..\]\])"
  exit 1
}


if [ -z "${1}" ]; then
  for i in $(ls */Dockerfile | sed 's/\(.*\)\/.*/\1/');
  do
    TMP="${TMP} ${i}"
  done
else
  while (( "$#" )); do
    TMP="${TMP} ${1}"
    shift
  done
fi

# Remove lead whitespace
LIST=$(echo ${TMP} | awk '$1=$1')

for i in ${LIST}; do
  build ${i}
done
