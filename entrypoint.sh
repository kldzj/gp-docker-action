#!/bin/sh

DOCKER_TOKEN=$1
DOCKER_IMAGE_TAG=$2
EXTRACT_SHA_FROM_COMMIT=$3
EXTRACT_TAG_FROM_GIT_REF=$4
DOCKERFILE=$5
BUILD_CONTEXT=$6
CUSTOM_DOCKER_BUILD_ARGS=$7

TAGS=()

if [ -n "$DOCKER_IMAGE_TAG" ]; then
  TAGS+=(DOCKER_IMAGE_TAG)
fi

if [ $EXTRACT_SHA_FROM_COMMIT == "true" ]; then
  TAGS+=($(git rev-parse --short HEAD))
fi

if [ $EXTRACT_TAG_FROM_GIT_REF == "true" ]; then
  TAGS+=($(echo ${GITHUB_REF} | sed -e "s/refs\/tags\///g"))
fi

docker login -u publisher -p ${DOCKER_TOKEN} ghcr.io

DOCKER_IMAGE_NAME="ghcr.io/${GITHUB_REPOSITORY}"
for tag in ${TAGS[*]}
do
  DOCKER_IMAGE_NAME_WITH_TAG=$(echo ${DOCKER_IMAGE_NAME}:${tag} | tr '[:upper:]' '[:lower:]')
  docker build -t $DOCKER_IMAGE_NAME_WITH_TAG -f $DOCKERFILE $CUSTOM_DOCKER_BUILD_ARGS $BUILD_CONTEXT
  docker push $DOCKER_IMAGE_NAME_WITH_TAG
done