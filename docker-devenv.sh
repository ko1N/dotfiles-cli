#!/bin/bash

VOLUME_NAME="devenv-home"
IMAGE_NAME="ko1n/devenv"

if ! docker volume inspect devenv-home >/dev/null 2>&1; then
  echo "docker volume '$VOLUME_NAME' does not exist. creating it..."
  docker volume create devenv-home
fi

if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "docker image '$IMAGE_NAME' does not exist. building it..."
  docker build -t "$IMAGE_NAME" .
fi

docker run --rm --volume devenv-home:/home/ko1N -it "$IMAGE_NAME":latest 
