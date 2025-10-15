#!/bin/bash

# Doris cluster management script

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

# Display usage
show_usage() {
    echo "Doris Cluster Management Tool"
    echo ""
    echo "Usage: ./manage-doris.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start       - Start Doris cluster"
    echo "  stop        - Stop Doris cluster"
    echo "  restart     - Restart Doris cluster"
    echo "  status      - Check cluster status"
    echo "  logs        - View logs (add -f to follow)"
    echo "  sql         - Execute SQL command (e.g., sql \"SHOW DATABASES;\")"
    echo "  connect     - Show connection information"
    echo "  clean       - Stop and remove volumes (WARNING: deletes all data)"
    echo ""
    echo "Examples:"
    echo "  ./manage-doris.sh start"
    echo "  ./manage-doris.sh logs -f"
    echo "  ./manage-doris.sh sql \"SHOW DATABASES;\""
}

# Show connection info
show_connection_info() {
    echo "📊 Doris Connection Information:"
    echo ""
    echo "MySQL Protocol:"
    echo "  Host: 127.0.0.1"
    echo "  Port: 9030"
    echo "  User: root"
    echo "  Password: (empty)"
    echo "  Command: mysql -uroot -P9030 -h127.0.0.1"
    echo ""
    echo "Web UI:"
    echo "  FE: http://127.0.0.1:8030"
    echo "  BE: http://127.0.0.1:8040"
    echo ""
    echo "Using Docker SQL client:"
    echo "  ./doris-sql.sh \"SHOW DATABASES;\""
}

# Main logic
case "$1" in
    start)
        echo "🚀 Starting Doris cluster..."
        ./start-doris.sh
        ;;
    stop)
        echo "🛑 Stopping Doris cluster..."
        $COMPOSE_CMD -f docker-compose-doris.yaml down
        echo "✅ Doris cluster stopped"
        ;;
    restart)
        echo "🔄 Restarting Doris cluster..."
        $COMPOSE_CMD -f docker-compose-doris.yaml down
        sleep 2
        ./start-doris.sh
        ;;
    status)
        echo "📊 Doris cluster status:"
        $COMPOSE_CMD -f docker-compose-doris.yaml ps
        echo ""
        echo "Container details:"
        docker ps --filter "name=dash-doris" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    logs)
        if [ "$2" = "-f" ]; then
            echo "📋 Following Doris logs (Ctrl+C to exit)..."
            $COMPOSE_CMD -f docker-compose-doris.yaml logs -f
        else
            echo "📋 Doris logs (last 50 lines):"
            $COMPOSE_CMD -f docker-compose-doris.yaml logs --tail=50
        fi
        ;;
    sql)
        if [ -z "$2" ]; then
            echo "Error: Please provide SQL command"
            echo "Example: ./manage-doris.sh sql \"SHOW DATABASES;\""
            exit 1
        fi
        ./doris-sql.sh "$2"
        ;;
    connect)
        show_connection_info
        ;;
    clean)
        echo "⚠️  WARNING: This will delete all Doris data!"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            echo "🧹 Cleaning up Doris cluster and data..."
            $COMPOSE_CMD -f docker-compose-doris.yaml down -v
            echo "✅ Cleanup completed"
        else
            echo "❌ Cleanup cancelled"
        fi
        ;;
    "")
        show_usage
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac

