#!/bin/sh

carton install

#TODO: fix it - it doesn't work inside mojo container.
# carton exec 'perl bin/run_migrations.pl --verbose'

exec "$@"
