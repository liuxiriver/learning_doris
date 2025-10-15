#!/bin/bash

# MySQL client wrapper for connecting to Doris
# This script uses the installed MySQL 8.4 client

MYSQL_BIN="/opt/homebrew/opt/mysql@8.4/bin/mysql"

if [ ! -f "$MYSQL_BIN" ]; then
    echo "Error: MySQL 8.4 client not found at $MYSQL_BIN"
    echo "Please install it with: brew install mysql@8.4"
    exit 1
fi

# Default connection parameters
HOST="127.0.0.1"
PORT="9030"
USER="root"

# Display usage
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "MySQL Client for Doris"
    echo ""
    echo "Usage:"
    echo "  Interactive mode:  ./mysql-client.sh"
    echo "  Execute SQL:       ./mysql-client.sh -e \"SHOW DATABASES;\""
    echo "  Execute from file: ./mysql-client.sh < query.sql"
    echo ""
    echo "Connection details:"
    echo "  Host: $HOST"
    echo "  Port: $PORT"
    echo "  User: $USER"
    echo "  Password: (empty)"
    exit 0
fi

# Connect to Doris
$MYSQL_BIN -u$USER -P$PORT -h$HOST "$@"

