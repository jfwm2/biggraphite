#!/bin/bash

for i in $(ls */Dockerfile | sed 's/\(.*\)\/.*/\1/');
do
  docker build ${i} -t ${i}
done
