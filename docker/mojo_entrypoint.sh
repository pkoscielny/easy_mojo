#!/bin/sh

carton install

echo "Running migrations..."
carton exec 'perl bin/run_migrations.pl'

exec "$@"
