#!/bin/bash
set -eou pipefail
# Install script for the project

if ! command -v pnpm &> /dev/null; then
  corepack prepare pnpm@latest --activate
else
  echo "✓ pnpm is installed, skipping."
fi

if [ ! -f .env ]; then
  cp .env.example .env
else
  echo "✓ .env file already exists, skipping."
fi

if [ ! -f ./pnpm-lock.yaml ] || [ ! -d ./node_modules ]; then
  pnpm install --no-frozen-lockfile
else
  echo "✓ Dependencies are already installed, skipping."
fi

if [ ! -d ./prisma/generated ]; then
  npx prisma generate
else
  echo "✓ Prisma client is already generated, skipping."
fi

is_docker_daemon_running=$(docker compose ps -q | grep "Cannot connect to the Docker daemon" || true)
if [ $is_docker_daemon_running ]; then
  echo "x Docker daemon is not running. Please start Docker and try again."
  exit 1
fi

docker compose pull
docker compose down --remove-orphans
docker compose up --build --remove-orphans -d

