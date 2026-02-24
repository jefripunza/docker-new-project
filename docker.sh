#!/bin/bash

APP_NAME="docker-new-project-codeigniter"
IMAGE_NAME="docker-new-project-codeigniter"

# Hapus file-file yang tidak perlu
echo "🗑️ Cleaning up..."

# Build ulang image
echo "🔨 Building Docker image..."
docker build --no-cache -t $IMAGE_NAME .

# Cek apakah container sudah ada
if [ "$(docker ps -aq -f name=^${APP_NAME}$)" ]; then
  echo "🛑 Stopping & removing old container..."
  docker stop $APP_NAME >/dev/null 2>&1
  docker rm $APP_NAME >/dev/null 2>&1
fi

# Run container baru
echo "🚀 Running new container..."
docker run -d --name $APP_NAME -p 8880:80 -p 8881:8080 $IMAGE_NAME

# http://localhost:8880
