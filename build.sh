#!/usr/bin/env bash
set -e

DOCKERFILE_NAME="Dockerfile.generated"
APP_NAME="$1"
IMAGE_NAME="polyglot-monorepo/$APP_NAME"

./make_dockerfile.rb "$APP_NAME" > "$DOCKERFILE_NAME"
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_NAME" .
