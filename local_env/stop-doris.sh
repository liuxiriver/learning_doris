#!/bin/bash

# Stop Doris cluster script

# Check docker-compose
COMPOSE_CMD=""
if command -v docker-compose &> /dev/null; then
  COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
  COMPOSE_CMD="docker compose"
else
  echo "Error: docker-compose plugin or docker-compose command is required"
  exit 1
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose-doris.yaml"

echo "Stopping Doris cluster..."
$COMPOSE_CMD -f "$COMPOSE_FILE" down

echo "✅ Doris cluster stopped successfully"
echo ""
echo "Other management commands:"
echo "  Start cluster: ./start-doris.sh"
echo "  View logs: $COMPOSE_CMD -f $COMPOSE_FILE logs -f"
echo "  Check status: $COMPOSE_CMD -f $COMPOSE_FILE ps"

