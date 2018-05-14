#!/bin/bash

NAMESPACE=${DSTF_NAMESPACE:='desiredstate'}
IMAGE=${DSTF_IMAGE:='dstf'}
TAG=${DSTF_VERSION:='latest'}
UPDATE=${DSTF_UPDATE:=true}

if ! hash docker &>/dev/null; then
    echo 'dStf > Docker is required to run dStf. Please install it and try again.'
    exit 1
fi

if [ "$UPDATE" = true ] ; then
    docker pull "${NAMESPACE}/${IMAGE}:${TAG}"
fi

docker run \
-ti \
--rm \
-v "$(pwd):/data" \
"${NAMESPACE}/${IMAGE}:${TAG}" \
"${@}"
