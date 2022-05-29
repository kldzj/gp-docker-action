#!/bin/bash

DOCKER_TOKEN=$1
DOCKER_IMAGE_TAG=$2
EXTRACT_TAG_FROM_COMMIT_SHA=$3
EXTRACT_TAG_FROM_GIT_REF=$4
DOCKERFILE=$5
BUILD_CONTEXT=$6
CUSTOM_DOCKER_BUILD_ARGS=$7
ADD_GIT_SAFE_DIRECTORY=$8

echo "Working directory: $(pwd)"
if [ "$ADD_GIT_SAFE_DIRECTORY" == "true" ]; then
  git config --global --add safe.directory $(pwd)
fi

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
  EXTRACTED_TAG=$(git describe --abbrev=0 --tags)
  echo "Extracted tag from git ref: $EXTRACTED_TAG"
  TAGS+=("$EXTRACTED_TAG")
fi

TAG_FLAGS=()
DOCKER_IMAGE_NAME="ghcr.io/${GITHUB_REPOSITORY}"
for TAG in "${TAGS[@]}"; do TAG_FLAGS+=(-t "$DOCKER_IMAGE_NAME:$TAG"); done

docker login -u publisher -p "${DOCKER_TOKEN}" ghcr.io
docker build "${TAG_FLAGS[@]}" -f "$DOCKERFILE" $CUSTOM_DOCKER_BUILD_ARGS "$BUILD_CONTEXT"
docker push "$DOCKER_IMAGE_NAME" --all-tags