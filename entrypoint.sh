#!/bin/bash
set -e

# Wait for PostgreSQL to start
until pg_isready -h db -p 5432; do
  echo "Waiting for PostgreSQL to start..."
  sleep 2
done

# If the database doesn't exist, create it
if [[ -z `psql -Atqc "\\list shortstop_development" postgres` ]]; then
  echo "Database does not exist. Creating..."
  rake db:create
fi

# Run pending migrations and prepare database
rake db:migrate
rake db:seed

# Remove server PID if it exists
rm -f /app/tmp/pids/server.pid

# Execute the command
exec "$@"