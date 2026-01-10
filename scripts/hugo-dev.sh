#!/bin/bash
# Hugo development server with live reload

CONTAINER_NAME="hugo-dev"
IMAGE_NAME="${HUGO_IMAGE:-hugo-dev:latest}"
PORT="${HUGO_PORT:-1313}"

podman run --rm -it \
  -p "${PORT}:1313" \
  -v "${PWD}:/src:z" \
  --name "${CONTAINER_NAME}" \
  "${IMAGE_NAME}" \
  hugo server -D --bind 0.0.0.0
