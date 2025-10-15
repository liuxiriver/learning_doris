#!/bin/bash

# Doris SQL execution helper (docker compose based)
# Usage:
#   ./doris-sql.sh "SHOW DATABASES;"
#   ./doris-sql.sh "CREATE DATABASE demo; USE demo; SHOW TABLES;"  # multiple statements in one session
#   ./doris-sql.sh -d demo "SELECT * FROM t;"                      # persistent default database
#   ./doris-sql.sh -f query.sql
#   ./doris-sql.sh -i

set -euo pipefail

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

if [ "$MODE" = "interactive" ]; then
  echo "[INFO] Interactive MySQL shell"
  $COMPOSE_CMD -f docker-compose-doris.yaml exec -T $FE_SVC mysql $MYSQL_ARGS
elif [ "$MODE" = "file" ]; then
  $COMPOSE_CMD -f docker-compose-doris.yaml exec -T $FE_SVC mysql $MYSQL_ARGS < "$SQL_FILE"
else
  if [ -z "$SQL_TEXT" ]; then
    echo "Error: Please provide SQL text"
    exit 1
  fi
  $COMPOSE_CMD -f docker-compose-doris.yaml exec -T $FE_SVC mysql $MYSQL_ARGS -e "$SQL_TEXT"
fi
