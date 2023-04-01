#!/bin/sh

carton install

if [ -n "$MOJO_DB_MIGRATIONS" ] && [ "$MOJO_DB_MIGRATIONS" -eq 1 ] ; then
    carton exec 'make prepare_database'

    echo "Running migrations ..."
    carton exec 'perl bin/run_migrations.pl'
fi 

if [ -n "$MOJO_MODE" ] && ([ "$MOJO_MODE" = "dev" ] || [ "$MOJO_MODE" = "test" ]); then
    echo "Running morbo ..."
    carton exec 'morbo -l  "http://*:3000" script/app.pl -w lib t config bin local script'
else
    echo "Running hypnotoad ..."
fi

exec "$@"
