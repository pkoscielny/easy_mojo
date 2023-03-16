#!/bin/sh

carton install

if [ -n "$MOJO_DB_MIGRATIONS" ] && [ "$MOJO_DB_MIGRATIONS" -eq 1 ] 
then
    echo "Running migrations ..."
    carton exec 'perl bin/run_migrations.pl'
fi 

if [ -n "$MOJO_MODE" ] && [ "$MOJO_MODE" = "dev" ]
then
    echo "Running morbo ..."
    carton exec 'morbo -l  "http://*:3000" script/app.pl -w .'
else
    echo "Running hypnotoad ..."
fi

exec "$@"
