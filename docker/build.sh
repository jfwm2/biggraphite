#!/bin/bash

for i in $(ls */Dockerfile | sed 's/\(.*\)\/.*/\1/');
do
 mkdir -p volumes_${i}  
 docker build ${i} -t ${i}
done

cp ../biggraphite/drivers/cassandra.py volumes_bg-cassandra/
