#!/bin/bash
# Hugo clean build (removes public/ and resources/ first)

IMAGE_NAME="${HUGO_IMAGE:-hugo-dev:latest}"

echo "Cleaning public/ and resources/..."
rm -rf public/ resources/

echo "Building Hugo site..."
podman run --rm -it \
  -v "${PWD}:/src:z" \
  "${IMAGE_NAME}" \
  --cleanDestinationDir
