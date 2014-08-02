#!/bin/bash
set -e
CONTAINER_NAME=dexy/asciidoctor
docker build -t $CONTAINER_NAME .
docker run -t -i \
    -v `pwd`:/home/repro/content \
    $CONTAINER_NAME /bin/bash
