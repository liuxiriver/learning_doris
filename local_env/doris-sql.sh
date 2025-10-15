#!/bin/bash

# Doris SQL execution helper (docker compose based)
# Usage:
#   ./doris-sql.sh "SHOW DATABASES;"
#   ./doris-sql.sh "CREATE DATABASE demo; USE demo; SHOW TABLES;"  # multiple statements in one session
#   ./doris-sql.sh -d demo "SELECT * FROM t;"                      # persistent default database
#   ./doris-sql.sh -f query.sql
#   ./doris-sql.sh -i

set -euo pipefail

# Resolve script directory to locate compose file reliably
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose-doris.yaml"

# Detect compose command
COMPOSE_CMD=""
if command -v docker-compose &> /dev/null; then
  COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
  COMPOSE_CMD="docker compose"
else
  echo "Error: docker-compose plugin or docker-compose command is required"
  exit 1
fi

# FE service name in compose
FE_SVC="fe"

# Optional default database
DB_NAME=""

if [ "$#" -eq 0 ]; then
  echo "Usage:"
  echo "  Execute SQL: ./doris-sql.sh \"SHOW DATABASES;\""
  echo "  Execute multiple: ./doris-sql.sh \"CREATE DATABASE demo; USE demo; SHOW TABLES;\""
  echo "  With default DB: ./doris-sql.sh -d demo \"SELECT * FROM t;\""
  echo "  Execute file: ./doris-sql.sh -f query.sql"
  echo "  Interactive: ./doris-sql.sh -i"
  exit 1
fi

# Parse args: -d|--database, -i, -f
MODE="cmd"
SQL_FILE=""
SQL_TEXT=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    -d|--database|-D)
      if [ -z "${2:-}" ]; then
        echo "Error: -d|--database requires a value"
        exit 1
      fi
      DB_NAME="$2"
      shift 2
      ;;
    -i)
      MODE="interactive"
      shift
      ;;
    -f)
      if [ -z "${2:-}" ]; then
        echo "Error: Please specify SQL file"
        exit 1
      fi
      MODE="file"
      SQL_FILE="$2"
      shift 2
      ;;
    *)
      # All remaining args compose the SQL string (first wins)
      if [ -z "$SQL_TEXT" ]; then
        SQL_TEXT="$1"
      else
        SQL_TEXT="$SQL_TEXT $1"
      fi
      shift
      ;;
  esac
done

# Common mysql args
MYSQL_ARGS="-uroot -P9030 -h127.0.0.1"
if [ -n "$DB_NAME" ]; then
  MYSQL_ARGS="$MYSQL_ARGS -D $DB_NAME"
fi

# Try to detect FE container for readiness checks
find_fe_container() {
  docker ps --filter label=com.docker.compose.service=fe --format '{{.Names}}' | head -n1
}

wait_mysql_ready() {
  local fe_container
  fe_container=$(find_fe_container)
  if [ -z "$fe_container" ]; then
    return 0
  fi

  local attempts=60
  local i=1
  while [ $i -le $attempts ]; do
    if docker exec -i "$fe_container" sh -lc "mysql -uroot -P9030 -h127.0.0.1 -e 'select 1'" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
    i=$((i+1))
  done
  echo "[WARN] FE MySQL port 9030 not ready after ${attempts}s; proceeding anyway"
}

# Wait (best-effort) for FE readiness
wait_mysql_ready

# Try compose exec first, then fallback to docker exec if service not found
compose_exec_mysql_cmd() {
  if [ "$1" = "interactive" ]; then
    $COMPOSE_CMD -f "$COMPOSE_FILE" exec -T $FE_SVC mysql $MYSQL_ARGS
  elif [ "$1" = "file" ]; then
    $COMPOSE_CMD -f "$COMPOSE_FILE" exec -T $FE_SVC mysql $MYSQL_ARGS < "$SQL_FILE"
  else
    $COMPOSE_CMD -f "$COMPOSE_FILE" exec -T $FE_SVC mysql $MYSQL_ARGS -e "$SQL_TEXT"
  fi
}

docker_exec_mysql_cmd() {
  # Prefer containers labeled as compose service=fe; fallback by name heuristic
  FE_CONTAINER=$(docker ps --filter label=com.docker.compose.service=fe --format '{{.Names}}' | head -n1)
  if [ -z "$FE_CONTAINER" ]; then
    FE_CONTAINER=$(docker ps --format '{{.Names}}' | grep -E '^doris-fe-\d+$' | head -n1 || true)
  fi
  if [ -z "$FE_CONTAINER" ]; then
    echo "Error: FE container not found for docker exec fallback"
    exit 1
  fi

  if [ "$1" = "interactive" ]; then
    docker exec -it "$FE_CONTAINER" mysql $MYSQL_ARGS
  elif [ "$1" = "file" ]; then
    docker exec -i "$FE_CONTAINER" mysql $MYSQL_ARGS < "$SQL_FILE"
  else
    docker exec -i "$FE_CONTAINER" sh -lc "mysql $MYSQL_ARGS -e \"$SQL_TEXT\""
  fi
}

MODE_TO_RUN="$MODE"
set +e
compose_exec_mysql_cmd "$MODE_TO_RUN"
STATUS=$?
set -e
if [ $STATUS -ne 0 ]; then
  echo "[WARN] compose exec failed (service may be under a different project). Falling back to docker exec..."
  docker_exec_mysql_cmd "$MODE_TO_RUN"
fi
