#!/bin/bash

for i in $(ls */Dockerfile | sed 's/\(.*\)\/.*/\1/');
do
 mkdir -p volumes_${i}  
 docker build .. -t ${i} -f ${i}/Dockerfile
done

mkdir -p volumes_graphite-aggregator-cache/conf
