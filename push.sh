#!/bin/bash
set -e

# ==============================
# Configuration
# ==============================
DOCKER_USERNAME="jefriherditriyanto"
IMAGE_NAME="docker-new-project"
PLATFORMS="linux/amd64,linux/arm64"

# ==============================
# Validation
# ==============================
if [ -z "$1" ]; then
  echo "❌ Version tag is required"
  echo "Usage: ./push-multiarch.sh v1.0.0"
  exit 1
fi

VERSION="$1"

# ==============================
# Build & Push (Multi-Arch)
# ==============================
echo "🚀 Building & pushing multi-arch image..."
echo "📦 Platforms: ${PLATFORMS}"

docker buildx build \
  --platform ${PLATFORMS} \
  -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION} \
  -t ${DOCKER_USERNAME}/${IMAGE_NAME}:latest \
  --push \
  .

echo "✅ Multi-arch image pushed successfully!"
echo "✔ ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
echo "✔ ${DOCKER_USERNAME}/${IMAGE_NAME}:latest"
