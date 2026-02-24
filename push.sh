#!/bin/bash

# ==============================
# Configuration
# ==============================
DOCKER_USERNAME="jefriherditriyanto"
IMAGE_NAME="docker-new-project-codeigniter"

# ==============================
# Validation
# ==============================
if [ -z "$1" ]; then
  echo "❌ Version tag is required"
  echo "Usage: ./push.sh v1.0.0"
  exit 1
fi

VERSION="$1"

# ==============================
# Build Image
# ==============================
echo "🚀 Building image..."
docker build -t ${IMAGE_NAME}:latest .

if [ $? -ne 0 ]; then
  echo "❌ Build failed"
  exit 1
fi

# ==============================
# Tag Image
# ==============================
echo "🏷️  Tagging images..."
docker tag ${IMAGE_NAME}:latest ${DOCKER_USERNAME}/${IMAGE_NAME}:latest
docker tag ${IMAGE_NAME}:latest ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}

# ==============================
# Push Image
# ==============================
echo "📤 Pushing latest..."
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:latest

echo "📤 Pushing ${VERSION}..."
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}

echo "✅ Done!"
echo "✔ ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
echo "✔ ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
