#!/bin/bash

DOCKER_TOKEN=$1
DOCKER_IMAGE_TAG=$2
EXTRACT_TAG_FROM_COMMIT_SHA=$3
EXTRACT_TAG_FROM_GIT_REF=$4
DOCKERFILE=$5
BUILD_CONTEXT=$6
CUSTOM_DOCKER_BUILD_ARGS=$7

TAGS=()
if [ -n "$DOCKER_IMAGE_TAG" ]; then
  echo "Fixed tag: $DOCKER_IMAGE_TAG"
  TAGS+=("$DOCKER_IMAGE_TAG")
fi

if [ "$EXTRACT_TAG_FROM_COMMIT_SHA" == "true" ]; then
  EXTRACTED_TAG=$(git rev-parse --short HEAD)
  echo "Extracted tag from commit sha: $EXTRACTED_TAG"
  TAGS+=("$EXTRACTED_TAG")
fi

if [ "$EXTRACT_TAG_FROM_GIT_REF" == "true" ]; then
  EXTRACTED_TAG="$(echo "${GITHUB_REF}" | sed -e "s/refs\/tags\///g")"
  echo "Extracted tag from git ref: $EXTRACTED_TAG"
  TAGS+=("$EXTRACTED_TAG")
fi

TAG_FLAGS=()
DOCKER_IMAGE_NAME="ghcr.io/${GITHUB_REPOSITORY}"
for tag in "${TAGS[@]}"; do TAG_FLAGS+=(-t "$DOCKER_IMAGE_NAME:$tag"); done

docker login -u publisher -p "${DOCKER_TOKEN}" ghcr.io
docker build "${TAG_FLAGS[@]}" -f "$DOCKERFILE" $CUSTOM_DOCKER_BUILD_ARGS "$BUILD_CONTEXT"
docker push "$DOCKER_IMAGE_NAME" --all-tags