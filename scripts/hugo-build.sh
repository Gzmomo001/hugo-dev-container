#!/bin/bash
# Hugo production build

IMAGE_NAME="${HUGO_IMAGE:-hugo-dev:latest}"

podman run --rm -it \
  -v "${PWD}:/src:z" \
  "${IMAGE_NAME}" \
  hugo
